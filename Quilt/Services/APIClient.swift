import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    var baseURL: URL = URL(string: "https://b6a2e7c1797c.ngrok-free.app")!

    // MARK: - Public

    func getPortfolio(token: String) async throws -> PortfolioResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("/portfolio/mock"))
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try assertOK(response, data: data, endpoint: "/portfolio")
        print("response \(response)")
        print("data \(data)")
        return try decodeWithLogging(PortfolioResponse.self, data: data, endpoint: "/portfolio/mock")
    }

    func getPrices(symbols: [String], token: String) async throws -> PricesResponse {
        let joined = symbols.map { $0.uppercased() }.joined(separator: ",")
        var comps = URLComponents(url: baseURL.appendingPathComponent("/prices"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "symbols", value: joined)]
        guard let url = comps.url else { throw NSError(domain: "BadURL", code: -1) }
        print("requesting url \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try assertOK(response, data: data, endpoint: "/prices")
        return try decodeWithLogging(PricesResponse.self, data: data, endpoint: "/prices")
    }
    
    func getLoginRedirect(brokerage: String, token: String) async throws -> LoginRedirectResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("/brokerages/login-redirect"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["brokerage": brokerage]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("token \(token)")

        let (data, response) = try await URLSession.shared.data(for: request)
        try assertOK(response, data: data, endpoint: "/login-redirect")

        let backend = try decodeWithLogging(LoginRedirectResponse.self, data: data, endpoint: "/login-redirect")

        return LoginRedirectResponse(
            redirectURI: backend.redirectURI,
            sessionId: backend.sessionId ?? ""
        )
    }

    // MARK: - Helpers

    private func assertOK(_ response: URLResponse, data: Data, endpoint: String) throws {
        guard let http = response as? HTTPURLResponse else {
            logRaw("(\(endpoint)) Non-HTTP response")
            throw NSError(domain: "NetworkError", code: -1)
        }
        guard (200..<300).contains(http.statusCode) else {
            logRaw("(\(endpoint)) HTTP \(http.statusCode)\nBody:\n\(String(data: data, encoding: .utf8) ?? "<non-utf8>")")
            throw NSError(domain: "NetworkError", code: http.statusCode)
        }
    }

    private func decodeWithLogging<T: Decodable>(_ type: T.Type, data: Data, endpoint: String) throws -> T {
        let decoder = JSONDecoder.iso8601Flexible() // <-- already handles fractional seconds
        do {
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(ctx) {
            logRaw("(\(endpoint)) DecodingError.dataCorrupted: \(ctx.debugDescription)\nContext: \(ctx.codingPath)")
        } catch let DecodingError.keyNotFound(key, ctx) {
            logRaw("(\(endpoint)) DecodingError.keyNotFound: \(key.stringValue)\nContext: \(ctx.debugDescription)\nPath: \(ctx.codingPath)")
        } catch let DecodingError.typeMismatch(type, ctx) {
            logRaw("(\(endpoint)) DecodingError.typeMismatch for \(type): \(ctx.debugDescription)\nPath: \(ctx.codingPath)")
        } catch let DecodingError.valueNotFound(type, ctx) {
            logRaw("(\(endpoint)) DecodingError.valueNotFound for \(type): \(ctx.debugDescription)\nPath: \(ctx.codingPath)")
        } catch {
            logRaw("(\(endpoint)) Unknown decode error: \(error)")
        }
        logRaw("(\(endpoint)) Raw body:\n\(String(data: data, encoding: .utf8) ?? "<non-utf8>")")
        throw NSError(domain: "DecodeError", code: -1)
    }

    private func logRaw(_ msg: String) {
        // Minimal logger; swap for os.Logger if you prefer
        print("❌ APIClient:", msg)
    }
}

// Flexible ISO8601 decoder (no need to override dateDecodingStrategy again)
extension JSONDecoder {
    static func iso8601Flexible() -> JSONDecoder {
        let dec = JSONDecoder()

        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let withoutFractional = ISO8601DateFormatter()
        withoutFractional.formatOptions = [.withInternetDateTime]

        dec.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let d = withFractional.date(from: str) { return d }
            if let d = withoutFractional.date(from: str) { return d }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(str)")
        }
        return dec
    }
}
