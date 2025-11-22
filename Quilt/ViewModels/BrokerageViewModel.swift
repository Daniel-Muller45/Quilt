import Foundation
import SwiftData

@MainActor
final class ConnectBrokerageViewModel: ObservableObject {
    // MARK: - State
    private var modelContext: ModelContext?
    @Published var isLinking = false
    @Published var error: String?
    @Published var redirectURL: URL?   // when set, present WebView / ASWebAuth

    // Optional cooldown to avoid repeated taps
    private var lastStart: Date?
    private let cooldown: TimeInterval = 5

    // MARK: - Bind
    func bind(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Actions

    /// Kick off SnapTrade linking. Provide the backend-facing brokerage slug (e.g., "charles_schwab").
    func startLink(brokerageSlug: String, token: String) async {
        guard shouldStart() else { return }
        isLinking = true
        error = nil
        defer { isLinking = false }

        do {
            let resp = try await APIClient.shared.getLoginRedirect(brokerage: brokerageSlug, token: token)
            guard let url = URL(string: resp.redirectURI) else {
                throw URLError(.badURL)
            }
            self.redirectURL = url
            self.lastStart = Date()
        } catch is CancellationError {
            // benign
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func startConnectionPortal(token: String) async {
        guard shouldStart() else { return }
        isLinking = true
        error = nil
        defer { isLinking = false }

        do {
            let resp = try await APIClient.shared.getLoginConnectionPortal(token: token)
            guard let url = URL(string: resp.redirectURI) else {
                throw URLError(.badURL)
            }
            self.redirectURL = url
            self.lastStart = Date()
        } catch is CancellationError {
            // benign
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Call this when your app receives the callback (e.g., quilt://callback?status=success&state=...).
    /// Optionally triggers a full portfolio refresh to pull in linked accounts.
    func handleCallback(_ callbackURL: URL, token: String, refreshAfterLink: Bool = true) async {
        // Clear the presented redirect so the sheet/ASWebAuth can dismiss
        self.redirectURL = nil

        // Parse any query params you care about
        let (status, state) = Self.parseStatusAndState(from: callbackURL)
        print("Link callback status=\(status ?? "nil"), state=\(state ?? "nil")")

        guard refreshAfterLink else { return }

        // Pull latest accounts/holdings after link completion
        if let ctx = modelContext {
            do {
                try await PortfolioService.syncFromBackend(modelContext: ctx, token: token)
                try await PricesService.refreshPrices(modelContext: ctx, token: token)
            } catch is CancellationError {
                // benign
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func clearRedirect() {
        self.redirectURL = nil
    }

    // MARK: - Helpers

    private func shouldStart() -> Bool {
        guard let last = lastStart else { return true }
        return Date().timeIntervalSince(last) > cooldown
    }

    private static func parseStatusAndState(from url: URL) -> (String?, String?) {
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return (nil, nil)
        }
        let status = comps.queryItems?.first(where: { $0.name == "status" })?.value
        let state  = comps.queryItems?.first(where: { $0.name == "state" })?.value
        return (status, state)
    }
}
