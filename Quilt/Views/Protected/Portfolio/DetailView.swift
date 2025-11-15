//import SwiftUI
//import Charts
//
//// MARK: - Models
//
//struct HoldingD: Identifiable, Hashable {
//    let id = UUID()
//    let symbol: String
//    let name: String
//    let quantity: Double
//    let currentValue: Double
//    let averageCost: Double
//    let totalReturnPercent: Double
//    let dayChangePercent: Double
//}
//
//struct ChartPoint: Identifiable {
//    let id = UUID()
//    let date: Date
//    let close: Double
//}
//
//
//// MARK: - Screen
//
//struct DetailView: View {
//    let holding: HoldingD
//
//    @State private var selectedTF: Timeframe = .y1
//    @State private var selectedTab: Int = 0 // 0 = Overview, 1 = Transactions
//
//    private let chartPoints: [ChartPoint] = DemoData.points // same set for all TFs for now
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//
//                // Title row
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack(alignment: .firstTextBaseline, spacing: 8) {
//                        Text(holding.symbol)
//                            .font(.system(size: 28, weight: .bold, design: .rounded))
//                        Text(holding.name)
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
//                    }
//
//                    HStack(spacing: 8) {
//                        Text(holding.currentValue, format: .currency(code: "USD"))
//                            .font(.title3.weight(.semibold))
//
//                        Text(String(format: "%+.2f%%", holding.dayChangePercent))
//                            .font(.subheadline.weight(.semibold))
//                            .foregroundStyle(holding.dayChangePercent >= 0 ? .green : .red)
//                    }
//                }
//
//                // Timeframe pills
//                TimeframePills(selected: $selectedTF)
//
//                // Chart
//                PriceChart(points: chartPoints)
//                    .frame(height: 240)
//                    .padding(.top, 4)
//
//                // Position section
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Position")
//                        .font(.headline)
//
//                    LazyVGrid(columns: [
//                        GridItem(.flexible(), alignment: .leading),
//                        GridItem(.flexible(), alignment: .leading)
//                    ], spacing: 14) {
//                        Metric(label: "Shares",
//                               value: Text(String(format: "%.2f", holding.quantity)))
//                        Metric(label: "Market Value",
//                               value: Text(holding.currentValue, format: .currency(code: "USD")))
//                        Metric(label: "Average Cost",
//                               value: Text(holding.averageCost, format: .currency(code: "USD")))
//                        Metric(label: "Total Return",
//                               value: HStack(spacing: 4) {
//                                   Text(String(format: "%+.2f%%", holding.totalReturnPercent))
//                                       .foregroundStyle(holding.totalReturnPercent >= 0 ? .green : .red)
//                               })
//                    }
//                }
//                .padding(.top, 8)
//
//                // Bottom segmented selector
//                SegmentedButtons(titles: ["Overview", "Transactions"], selectedIndex: $selectedTab)
//                    .padding(.top, 8)
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 16)
//        }
//        .background(Color.black.ignoresSafeArea())
//        .navigationTitle(holding.symbol)
//        .navigationBarTitleDisplayMode(.inline)
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Subviews
//
//struct TimeframePills: View {
//    @Binding var selected: Timeframe
//
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(Timeframe.allCases) { tf in
//                Button {
//                    selected = tf
//                } label: {
//                    Text(tf.rawValue)
//                        .font(.footnote.weight(.semibold))
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(
//                            Capsule()
//                                .fill(selected == tf ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
//                        )
//                        .overlay(
//                            Capsule()
//                                .stroke(selected == tf ? Color.white.opacity(0.35) : Color.white.opacity(0.12), lineWidth: 1)
//                        )
//                }
//                .buttonStyle(.plain)
//            }
//            Spacer()
//        }
//    }
//}
//
//struct PriceChart: View {
//    let points: [ChartPoint]
//
//    var body: some View {
//        Chart(points) { p in
//            LineMark(
//                x: .value("Date", p.date),
//                y: .value("Close", p.close)
//            )
//            .interpolationMethod(.catmullRom)
//
//            AreaMark(
//                x: .value("Date", p.date),
//                y: .value("Close", p.close)
//            )
//            .interpolationMethod(.catmullRom)
//            .opacity(0.18)
//        }
//        .chartXAxis {
//            AxisMarks(values: .automatic(desiredCount: 4))
//        }
//        .chartYAxis {
//            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4))
//        }
//        .chartYScale(domain: .automatic(includesZero: false))
//    }
//}
//
//struct Metric: View {
//    let label: String
//    let value: AnyView
//
//    init<V: View>(label: String, value: V) {
//        self.label = label
//        self.value = AnyView(value)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(label)
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            value
//                .font(.subheadline.weight(.semibold))
//        }
//    }
//}
//
//struct SegmentedButtons: View {
//    let titles: [String]
//    @Binding var selectedIndex: Int
//
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(titles.indices, id: \.self) { i in
//                Button {
//                    selectedIndex = i
//                } label: {
//                    Text(titles[i])
//                        .font(.subheadline.weight(.semibold))
//                        .padding(.horizontal, 14)
//                        .padding(.vertical, 10)
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            Capsule()
//                                .fill(i == selectedIndex ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
//                        )
//                        .overlay(
//                            Capsule()
//                                .stroke(i == selectedIndex ? Color.white.opacity(0.35) : Color.white.opacity(0.12), lineWidth: 1)
//                        )
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(6)
//        .background(
//            RoundedRectangle(cornerRadius: 28, style: .continuous)
//                .fill(Color.white.opacity(0.04))
//        )
//    }
//}
//
//// MARK: - Demo
//
//enum DemoData {
//    static var points: [ChartPoint] {
//        // hard-coded, lightly wavy data over ~1 year
//        let start = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
//        let closes: [Double] = [
//            92, 95, 94, 97, 105, 120, 135, 150, 138, 126, 118, 110, 112, 109, 115, 123, 132, 145, 152, 148,
//            142, 139, 141, 147, 149, 155, 160, 158, 150, 144, 146, 151, 153, 149, 140, 137, 143, 148, 150, 147,
//            149, 151, 156, 162, 159, 154, 150, 146, 142, 138, 140, 144
//        ]
//        return closes.enumerated().map { i, c in
//            ChartPoint(date: Calendar.current.date(byAdding: .day, value: i * 7, to: start)!, close: c)
//        }
//    }
//
//    static let holding = HoldingD(
//        symbol: "CRWV",
//        name: "CoreWeave, Inc.",
//        quantity: 2.51,
//        currentValue: 1706.14,
//        averageCost: 541.20,
//        totalReturnPercent: 24.30,
//        dayChangePercent: 130.58
//    )
//}
//
//// MARK: - Preview
//
//struct PositionDetailScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            DetailView(holding: DemoData.holding)
//        }
//        .preferredColorScheme(.dark)
//    }
//}
