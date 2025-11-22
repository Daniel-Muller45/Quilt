//
//  PortfolioService.swift
//

import Foundation
import SwiftData

enum PortfolioService {
    @MainActor
    static func syncFromBackend(modelContext: ModelContext, token: String) async throws {
        let resp = try await APIClient.shared.getPortfolio(token: token)

        try modelContext.transaction {
            // Ensure singleton Portfolio exists
            let portfolio: Portfolio = {
                var pDesc = FetchDescriptor<Portfolio>()
                pDesc.fetchLimit = 1
                if let existing = try? modelContext.fetch(pDesc).first {
                    return existing
                } else {
                    let p = Portfolio(name: "My Portfolio", asOf: resp.asOf) // assumes Portfolio has no remoteID
                    modelContext.insert(p)
                    return p
                }
            }()

            portfolio.asOf = resp.asOf

            // Upsert accounts
            var seenAccountIDs = Set<String>()
            for a in resp.accounts {
                let account = upsertAccount(dto: a, ctx: modelContext, portfolio: portfolio)
                account.lastSyncedAt = resp.asOf
                seenAccountIDs.insert(a.id)
            }

            // Delete accounts not present
            do {
                var allAccountsDesc = FetchDescriptor<Account>()
                let existingAccounts = try modelContext.fetch(allAccountsDesc)
                for acc in existingAccounts where !seenAccountIDs.contains(acc.remoteID) {
                    modelContext.delete(acc) // cascades holdings
                }
            } catch {
                // MVP: ignore fetch/delete errors; consider logging
            }

            // Upsert holdings
            var seenHoldingIDs = Set<String>()
            for h in resp.holdings {
                // find parent account (capture RHS value first for #Predicate)
                let accId = h.accountId
                var accDesc = FetchDescriptor<Account>(
                    predicate: #Predicate<Account> { $0.remoteID == accId }
                )
                accDesc.fetchLimit = 1
                guard let account = try? modelContext.fetch(accDesc).first else { continue }

                let holding = upsertHolding(dto: h, ctx: modelContext, account: account, asOf: resp.asOf)
                seenHoldingIDs.insert(holding.remoteID)
            }

            // Delete holdings not present
            do {
                var allHoldingsDesc = FetchDescriptor<Holding>()
                let existingHoldings = try modelContext.fetch(allHoldingsDesc)
                for h in existingHoldings where !seenHoldingIDs.contains(h.remoteID) {
                    modelContext.delete(h)
                }
            } catch {
                // MVP: ignore fetch/delete errors; consider logging
            }
        }
    }

    @MainActor
    private static func upsertAccount(dto: AccountDTO, ctx: ModelContext, portfolio: Portfolio) -> Account {
        let id = dto.id
        var desc = FetchDescriptor<Account>(
            predicate: #Predicate<Account> { $0.remoteID == id }
        )
        desc.fetchLimit = 1

        if let existing = try? ctx.fetch(desc).first {
            existing.name = dto.name
            existing.brokerage = dto.brokerage
            existing.currency = dto.currency
            existing.portfolio = portfolio
            return existing
        } else {
            let fresh = Account(
                remoteID: dto.id,
                name: dto.name,
                brokerage: dto.brokerage,
                currency: dto.currency,
                portfolio: portfolio
            )
            ctx.insert(fresh)
            return fresh
        }
    }

    @MainActor
    private static func upsertHolding(
        dto: HoldingDTO,
        ctx: ModelContext,
        account: Account,
        asOf: Date
    ) -> Holding {
        let id = dto.id
        let accountID = account.remoteID

        var desc = FetchDescriptor<Holding>(
            predicate: #Predicate<Holding> { holding in
                holding.remoteID == id &&
                holding.account?.remoteID == accountID
            }
        )
        desc.fetchLimit = 1

        if let existing = try? ctx.fetch(desc).first {
            existing.symbol = dto.symbol
            existing.quantity = dto.quantity
            existing.avgCost = dto.avgCost
            existing.updatedAt = asOf
            existing.account = account
            return existing
        } else {
            let fresh = Holding(
                remoteID: dto.id,
                symbol: dto.symbol,
                symbolDescription: dto.symbolDescription,
                quantity: dto.quantity,
                avgCost: dto.avgCost,
                updatedAt: asOf,
                account: account
            )
            ctx.insert(fresh)
            return fresh
        }
    }

}
