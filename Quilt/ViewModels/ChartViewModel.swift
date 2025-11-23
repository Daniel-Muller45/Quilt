import Foundation
import Supabase

@MainActor
final class OneYearChartViewModel: ObservableObject {
    @Published var points: [EODRow] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(ticker: String) {
        isLoading = true
        error = nil
        Task {
            do {
                let rows = try await SupabaseService.shared.fetchOneYearEOD(ticker: ticker)
                self.points = rows
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    var latestPrice: Double? { points.last?.close }
    var pctReturn1Y: Double? {
        guard let first = points.first?.close, let last = points.last?.close, first > 0 else { return nil }
        return (last / first - 1) * 100
    }
}

@MainActor
final class StockHistoryViewModel: ObservableObject {
    @Published var snapshots: [StockSnapshot] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(ticker: String) async {
        isLoading = true
        error = nil

        do {
            let client = SupabaseService.shared.client

            let rows: [StockSnapshot] = try await client
                .database
                .from("daily_stock_data")
                .select("date,ticker,close")
                .eq("ticker", value: ticker)
                .order("date", ascending: true)
                .execute()
                .value

            self.snapshots = rows
        } catch {
            print("Failed to load stock snapshots for ticker \(ticker):", error)
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
