import Foundation
import SwiftData


@Model
final class Portfolio {
    var name: String
    var asOf: Date
    @Relationship(deleteRule: .cascade, inverse: \Account.portfolio)
    var accounts: [Account] = []

    init(name: String, asOf: Date) {
        self.name = name
        self.asOf = asOf
    }

    var totalValue: Double {
        accounts.reduce(0) { $0 + $1.totalValue }
    }
}

@Model
final class Account {
    @Attribute(.unique) var remoteID: String
    var name: String
    var brokerage: String
    var currency: String
    var lastSyncedAt: Date?
    @Relationship var portfolio: Portfolio?
    @Relationship(deleteRule: .cascade, inverse: \Holding.account)
    var holdings: [Holding] = []

    init(remoteID: String, name: String, brokerage: String, currency: String, lastSyncedAt: Date? = nil, portfolio: Portfolio? = nil) {
        self.remoteID = remoteID
        self.name = name
        self.brokerage = brokerage
        self.currency = currency
        self.lastSyncedAt = lastSyncedAt
        self.portfolio = portfolio
    }

    var totalValue: Double {
        holdings.reduce(0) { $0 + $1.marketValue }
    }
}

@Model
final class Holding {
    @Attribute(.unique) var remoteID: String
    var symbol: String
    var quantity: Double
    var avgCost: Double
    var marketPrice: Double?
    var updatedAt: Date
    var priceAsOf: Date?
    var prevClose: Double?
    @Relationship var account: Account?

    init(remoteID: String, symbol: String, quantity: Double, avgCost: Double, marketPrice: Double? = nil, updatedAt: Date, account: Account? = nil) {
        self.remoteID = remoteID
        self.symbol = symbol
        self.quantity = quantity
        self.avgCost = avgCost
        self.marketPrice = marketPrice
        self.updatedAt = updatedAt
        self.account = account
    }

    var marketValue: Double {
        (marketPrice ?? 0) * quantity
    }

    var gain: Double {
        marketValue - (avgCost * quantity)
    }
}

extension Holding {
    /// Current market value using the stored marketPrice; falls back to 0 if nil
    var currentValue: Double { (marketPrice ?? 0) * quantity }

    /// Market value at previous close (if we have prevClose)
    var prevCloseValue: Double? {
        guard let pc = prevClose else { return nil }
        return pc * quantity
    }

    /// Day change % for this holding, based on last vs prevClose
    var dayChangePercent: Double? {
        guard let last = marketPrice, let pc = prevClose, pc > 0 else { return nil }
        return (last - pc) / pc * 100.0
    }
}

extension Account {
    /// Sum of current market values across holdings
    var currentValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    /// Sum of previous-close market values (only counts holdings that have prevClose)
    var prevCloseValue: Double? {
        let pairs = holdings.compactMap { $0.prevCloseValue }
        guard !pairs.isEmpty else { return nil }
        return pairs.reduce(0, +)
    }

    /// Account-level day % change (weighted by position sizes)
    var dayChangePercent: Double? {
        guard let prev = prevCloseValue, prev > 0 else { return nil }
        let cur = currentValue
        return (cur - prev) / prev * 100.0
    }
}

struct EODRow: Decodable, Identifiable {
    let id = UUID()
    let date: String         // "yyyy-MM-dd" coming from PostgREST
    let close: Double

    var dateValue: Date {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: date) ?? .distantPast
    }
}

