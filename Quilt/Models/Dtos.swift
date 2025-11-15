import Foundation


struct PortfolioResponse: Decodable {
    let asOf: Date
    let accounts: [AccountDTO]
    let holdings: [HoldingDTO]
}

struct AccountDTO: Decodable {
    let id: String
    let name: String
    let brokerage: String
    let currency: String
}

struct HoldingDTO: Decodable {
    let id: String
    let accountId: String
    let symbol: String
    let quantity: Double
    let avgCost: Double
}

public struct PricesResponse: Decodable {
    public let asOf: Date
    public let quotes: [PriceQuoteDTO]
    public let errors: [PriceErrorDTO]
}

public struct PriceQuoteDTO: Decodable {
    public let symbol: String
    public let last: Double?
    public let prevClose: Double?
    public let asOf: Date
    public let currency: String?
    public let source: String
    public let isDelayed: Bool
    public let cachedUntil: Date
    public let stale: Bool
}

public struct PriceErrorDTO: Decodable {
    public let symbol: String
    public let message: String
}

public struct LoginRedirectResponse: Decodable {
    let redirectURI: String
    let sessionId: String?
}
