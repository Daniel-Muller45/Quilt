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
    var remoteID: String
    var symbol: String
    var symbolDescription: String
    var quantity: Double
    var avgCost: Double
    var marketPrice: Double?
    var updatedAt: Date
    var priceAsOf: Date?
    var prevClose: Double?
    @Relationship var account: Account?

    init(remoteID: String, symbol: String, symbolDescription: String, quantity: Double, avgCost: Double, marketPrice: Double? = nil, updatedAt: Date, account: Account? = nil) {
        self.remoteID = remoteID
        self.symbol = symbol
        self.symbolDescription = symbolDescription
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
    var currentValue: Double { (marketPrice ?? 0) * quantity }

    var prevCloseValue: Double? {
        guard let pc = prevClose else { return nil }
        return pc * quantity
    }

    var dayChangePercent: Double? {
        guard let last = marketPrice, let pc = prevClose, pc > 0 else { return nil }
        return (last - pc) / pc * 100.0
    }
}

extension Account {
    var currentValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    var prevCloseValue: Double? {
        let pairs = holdings.compactMap { $0.prevCloseValue }
        guard !pairs.isEmpty else { return nil }
        return pairs.reduce(0, +)
    }

    var dayChangePercent: Double? {
        guard let prev = prevCloseValue, prev > 0 else { return nil }
        let cur = currentValue
        return (cur - prev) / prev * 100.0
    }
}

struct EODRow: Decodable, Identifiable {
    let id = UUID()
    let date: String
    let close: Double

    var dateValue: Date {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: date) ?? .distantPast
    }
}

struct DailySnapshot: Identifiable, Decodable {
    let id: Int
    let date: String
    let totalValue: Double

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case totalValue = "total_value"
    }
    
    var dateValue: Date {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: date) ?? .distantPast
    }
}

enum TimeframePerformance: String, CaseIterable, Identifiable {
    case d1 = "1D"
    case w1 = "1W"
    case m1 = "1M"
    case m3 = "3M"
    case y1 = "1Y"
    case y5 = "5Y"
    case all = "ALL"

    var id: String { rawValue }

    func startDate(from now: Date = Date()) -> Date? {
        let cal = Calendar.current
        switch self {
        case .d1:  return cal.date(byAdding: .day, value: -1, to: now)
        case .w1:  return cal.date(byAdding: .day, value: -7, to: now)
        case .m1:  return cal.date(byAdding: .month, value: -1, to: now)
        case .m3:  return cal.date(byAdding: .month, value: -3, to: now)
        case .y1:  return cal.date(byAdding: .year, value: -1, to: now)
        case .y5:  return cal.date(byAdding: .year, value: -5, to: now)
        case .all: return nil
        }
    }
}

struct PerformancePoint: Identifiable {
    let id = UUID()
    let date: String
    let value: Double
}

struct PortfolioSnapshot: Identifiable, Decodable {
    let id = UUID()
    let date: Date
    let totalValue: Double

    enum CodingKeys: String, CodingKey {
        case date
        case totalValue = "total_value"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode date as String from Supabase, then parse "yyyy-MM-dd"
        let dateString = try container.decode(String.self, forKey: .date)

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        guard let parsedDate = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }

        self.date = parsedDate
        self.totalValue = try container.decode(Double.self, forKey: .totalValue)
    }
}
