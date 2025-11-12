import SwiftUI
import Charts


enum Timeframe: String, CaseIterable, Identifiable {
    case d1 = "1D"
    case w1 = "1W"
    case m6 = "6M"
    case ytd = "YTD"
    case y1 = "1Y"
    case y5 = "5Y"

    var id: String { rawValue }
}

struct PositionDetailView: View {
    let holding: Holding

    @State private var selectedTF: Timeframe = .y1
    @State private var selectedTab: Int = 0
    @StateObject private var vm = OneYearChartViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // existing header + summary...
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(holding.symbol).font(.largeTitle).fontWeight(.bold)
//                    Text(String(format: "%.2f shares", holding.quantity))
//                        .font(.title3).foregroundColor(.secondary)
//                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(holding.symbol)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("CoreWeave, Inc.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    HStack(spacing: 8) {
                        Text(holding.currentValue, format: .currency(code: "USD"))
                            .font(.title3.weight(.semibold))
                        if let pct = vm.pctReturn1Y {
                            Text(String(format: "%+.2f%%", pct))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(pct >= 0 ? .green : .red)
                        }
                    }
                    .onAppear { vm.load(ticker: holding.symbol) }
                }

                Divider()
                
                TimeframePills(selected: $selectedTF)

//                VStack(alignment: .leading, spacing: 8) {
//                    Text(holding.currentValue, format: .currency(code: "USD")).font(.headline)
//                    if let pct = holding.dayChangePercent {
//                        Text(String(format: "%+.2f%%", pct))
//                            .font(.subheadline).fontWeight(.semibold)
//                            .foregroundColor(pct >= 0 ? .green : .red)
//                    }
//                }

                // NEW: 1Y chart
                OneYearPriceChart(symbol: holding.symbol)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Position")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ], spacing: 14) {
                        Metric(label: "Shares",
                               value: Text(String(format: "%.2f", holding.quantity)))
                        Metric(label: "Market Value",
                               value: Text(holding.currentValue, format: .currency(code: "USD")))
                        Metric(label: "Average Cost",
                               value: Text(holding.avgCost, format: .currency(code: "USD")))
                        if let marketPrice = holding.marketPrice {
                            let pctReturn = ((marketPrice - holding.avgCost) / holding.avgCost) * 100
                            Metric(label: "Total Return",
                                   value: HStack(spacing: 4) {
                                       Text(String(format: "%+.2f%%", pctReturn))
                                           .foregroundStyle(pctReturn >= 0 ? .green : .red)
                                   })
                        }

//                        Metric(label: "Total Return",
//                               value: HStack(spacing: 4) {
//                                   Text(String(format: "%+.2f%%", holding.totalReturnPercent))
//                                       .foregroundStyle(holding.totalReturnPercent >= 0 ? .green : .red)
//                               })
                    }
                }
                .padding(.top, 8)
                
                SegmentedButtons(titles: ["Overview", "Transactions"], selectedIndex: $selectedTab)
                    .padding(.top, 8)
                
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
                    if let pct = vm.pctReturn1Y {
                        LineMark(
                            x: .value("Date", p.dateValue),
                            y: .value("Close", p.close)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(pct >= 0 ? .green : .red)
                        AreaMark(
                            x: .value("Date", p.dateValue),
                            y: .value("Close", p.close)
                        )
                        .foregroundStyle(pct >= 0 ? .green : .red)
                        .opacity(0.15)
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 240)
            }
        }
        .onAppear { vm.load(ticker: symbol) }
    }
}

struct TimeframePills: View {
    @Binding var selected: Timeframe

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Timeframe.allCases) { tf in
                Button {
                    selected = tf
                } label: {
                    Text(tf.rawValue)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selected == tf ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selected == tf ? Color.white.opacity(0.35) : Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

struct Metric: View {
    let label: String
    let value: AnyView

    init<V: View>(label: String, value: V) {
        self.label = label
        self.value = AnyView(value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            value
                .font(.subheadline.weight(.semibold))
        }
    }
}

struct SegmentedButtons: View {
    let titles: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(titles.indices, id: \.self) { i in
                Button {
                    selectedIndex = i
                } label: {
                    Text(titles[i])
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(i == selectedIndex ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(i == selectedIndex ? Color.white.opacity(0.35) : Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}
