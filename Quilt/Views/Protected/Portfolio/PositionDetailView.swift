import SwiftUI
import Charts

struct PositionDetailView: View {
    let position: Position

    // Mock price history (past 7 days)
    @State private var priceHistory: [PricePoint] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(position.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(String(format: "%.2f shares", position.shares))
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Price summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Value: \(position.value.formatted(.currency(code: "USD")))")
                    .font(.headline)
                Text(String(format: "Daily Change: %+.2f%%", position.change))
                    .font(.headline)
                    .foregroundColor(position.change >= 0 ? .green : .red)
            }

            // Chart
            if !priceHistory.isEmpty {
                Chart(priceHistory) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        position.change >= 0
                        ? Gradient(colors: [.green, .green.opacity(0.3)])
                        : Gradient(colors: [.red, .red.opacity(0.3)])
                    )

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                position.change >= 0 ? .green.opacity(0.3) : .red.opacity(0.3),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 240)
                .padding(.top)
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day(.defaultDigits))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(position.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateMockPriceData()
        }
    }

    // Mock 7-day price data
    private func generateMockPriceData() {
        let now = Date()
        let prices = stride(from: 0, to: 7, by: 1).map { i -> PricePoint in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: now)!
            let base = position.value / Double(position.shares)
            let randomFluctuation = Double.random(in: -0.05...0.05)
            let price = base * (1 + randomFluctuation)
            return PricePoint(date: date, price: price)
        }
        priceHistory = prices.sorted { $0.date < $1.date }
    }
}

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

#Preview {
    PositionDetailView(position: Position(symbol: "AAPL", shares: 10.25, value: 2450.00, change: 1.52))
}
