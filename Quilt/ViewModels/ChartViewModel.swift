import Foundation

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
