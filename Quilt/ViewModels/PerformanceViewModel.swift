import Foundation
import Supabase

@MainActor
final class PortfolioHistoryViewModel: ObservableObject {
    @Published var snapshots: [PortfolioSnapshot] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        error = nil

        do {
            let client = SupabaseService.shared.client

            let rows: [PortfolioSnapshot] = try await client
                .database
                .from("portfolio_snapshots")
                .select("date,total_value")
                .order("date", ascending: true)
                .execute()
                .value

            self.snapshots = rows
        } catch {
            print("Failed to load portfolio snapshots:", error)
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

enum HistoryTimeframe: String, CaseIterable, Identifiable {
    case d1 = "1D"
    case w1 = "1W"
    case m3 = "3M"
    case m6 = "6M"
    case y1 = "1Y"
    case y2 = "2Y"
    case all = "All"

    var id: String { rawValue }
}

