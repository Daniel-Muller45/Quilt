import Foundation
import SwiftData

@MainActor
final class PortfolioViewModel: ObservableObject {
    private var modelContext: ModelContext?
    @Published var isSyncing = false
    @Published var error: String?

    // Optional: simple cooldown to avoid spam
    private var lastRefresh: Date?
    private let cooldown: TimeInterval = 60

    func bind(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    private func shouldRefresh() -> Bool {
        guard let last = lastRefresh else { return true }
        return Date().timeIntervalSince(last) > cooldown
    }

    func refreshAll(token: String) async {
        guard !isSyncing, let ctx = modelContext, shouldRefresh() else { return }
        isSyncing = true; error = nil
        defer { isSyncing = false }
        do {
            try await PortfolioService.syncFromBackend(modelContext: ctx, token: token)
            try await PricesService.refreshPrices(modelContext: ctx, token: token)
            lastRefresh = Date()
        } catch is CancellationError {
            // benign: SwiftUI cancelled a task because a new one started
            return
        } catch {
            self.error = error.localizedDescription
        }
    }

    func refreshPricesOnly(token: String) async {
        guard !isSyncing, let ctx = modelContext else { return }
        // no cooldown here if you want snappier foreground refreshes
        isSyncing = true; error = nil
        defer { isSyncing = false }
        do {
            print("syncing on refresh")
            try await PricesService.refreshPrices(modelContext: ctx, token: token)
        } catch is CancellationError {
            return
        } catch {
            self.error = error.localizedDescription
        }
    }
    

}
