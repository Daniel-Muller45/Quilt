import Foundation
import SwiftData

enum PricesService {
    @MainActor
    static func refreshPrices(modelContext: ModelContext, token: String) async throws {
        // 1) Fetch all holdings once
        let holdings = try modelContext.fetch(FetchDescriptor<Holding>())

        // 2) Build unique symbol set for the API (uppercased)
        let symbols = Array(
            Set(
                holdings
                    .compactMap { $0.symbol }
                    .filter { !$0.isEmpty }
                    .map { $0.uppercased() }
            )
        )
        guard !symbols.isEmpty else { return }

        // 3) Call backend
        let resp = try await APIClient.shared.getPrices(symbols: symbols, token: token)

        // 4) Build an in-memory index: UPPER(symbol) -> [Holding]
        let index = Dictionary(grouping: holdings, by: { $0.symbol.uppercased() })

        // 5) Apply updates in a single transaction
        try modelContext.transaction {
            for quote in resp.quotes {
                let key = quote.symbol.uppercased()
                guard let matches = index[key] else { continue }
                for h in matches {
                    h.marketPrice = quote.last
                    h.prevClose = quote.prevClose
                    h.priceAsOf = quote.asOf
                }
            }
        }
    }
}
