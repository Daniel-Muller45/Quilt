import SwiftUI
import Charts

struct PositionDetailView: View {
    let holding: Holding

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // existing header + summary...
                VStack(alignment: .leading, spacing: 4) {
                    Text(holding.symbol).font(.largeTitle).fontWeight(.bold)
                    Text(String(format: "%.2f shares", holding.quantity))
                        .font(.title3).foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(holding.currentValue, format: .currency(code: "USD")).font(.headline)
                    if let pct = holding.dayChangePercent {
                        Text(String(format: "%+.2f%%", pct))
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(pct >= 0 ? .green : .red)
                    }
                }

                // NEW: 1Y chart
                OneYearPriceChart(symbol: holding.symbol)
            }
            .padding()
            .navigationTitle(holding.symbol)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct OneYearPriceChart: View {
    let symbol: String
    @StateObject private var vm = OneYearChartViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if vm.isLoading {
                ProgressView("Loading \(symbol)…")
            } else if let err = vm.error {
                Text("Error: \(err)").foregroundColor(.red)
            } else if vm.points.isEmpty {
                Text("No data")
            } else {
                Chart(vm.points) { p in
                    LineMark(
                        x: .value("Date", p.dateValue),
                        y: .value("Close", p.close)
                    )
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("Date", p.dateValue),
                        y: .value("Close", p.close)
                    )
                    .opacity(0.15)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 240)

                HStack(spacing: 8) {
                    if let last = vm.latestPrice {
                        Text(last, format: .currency(code: "USD")).fontWeight(.semibold)
                    }
                    if let pct = vm.pctReturn1Y {
                        Text(String(format: "%+.2f%% 1Y", pct))
                            .foregroundColor(pct >= 0 ? .green : .red)
                    }
                }
                .font(.subheadline)
            }
        }
        .onAppear { vm.load(ticker: symbol) }
    }
}
