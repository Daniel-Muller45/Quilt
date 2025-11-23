import SwiftUI
import Charts
// SupabaseService is assumed to be defined elsewhere and available
// Holding struct, OneYearChartViewModel, StockHistoryChartView, HistoryTimeframe, etc. are assumed to be defined and available

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

    @State private var selectedTab: Int = 0
    // @StateObject private var vm = OneYearChartViewModel() // Removed: Assuming chart VM is handled elsewhere
    @StateObject private var transactionVM = TransactionViewModel() // NEW: Transaction view model
    @State private var timeframe: HistoryTimeframe = .d1 // Assuming HistoryTimeframe is defined elsewhere
    @State private var selectedTimeframe: Timeframe = .d1
    private let timeframes = Timeframe.allCases
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(holding.symbolDescription)
                            .font(.system(size: 28, weight: .bold))
                    }
                    
                    // Assuming StockHistoryChartView is defined
                    StockHistoryChartView(selectedTimeframe: $selectedTimeframe, ticker: holding.symbol)
                    timeFramePicker
                }

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
                    }
                }
                .padding(.top, 8)
                
                SegmentedButtons(titles: ["Overview", "Transactions"], selectedIndex: $selectedTab)
                    .padding(.top, 8)
                
                // NEW: Content based on selected tab
                Group {
                    if selectedTab == 0 {
                        // Overview content placeholder
                        // You can add stock fundamentals, news, etc. here later
                        Color.clear.frame(height: 1)
                    } else if selectedTab == 1 {
                        TransactionListView(ticker: holding.symbol, transactionVM: transactionVM)
                            // Load data only when the Transactions tab is selected
                            .onAppear {
                                Task {
                                    await transactionVM.load(ticker: holding.symbol)
                                }
                            }
                    }
                }
                .padding(.top, 16)

            }
            .padding()
            .navigationTitle(holding.symbol)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var timeFramePicker: some View {
        HStack(spacing: 16) {
            Spacer()
            ForEach(timeframes) { tf in
                Button {
                    withAnimation(.easeInOut) {
                        selectedTimeframe = tf
                    }
                } label: {
                    Text(tf.rawValue)
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(selectedTimeframe == tf
                                            ? Color.secondary.opacity(0.15)
                                            : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedTimeframe == tf ? Color.white.opacity(0.35) : Color.white.opacity(0.0), lineWidth: 1)
                        )
                        .foregroundColor(selectedTimeframe == tf ? .primary : .secondary)
                }
            }
            Spacer()
        }
    }
}

// NEW: Transaction List View (Displayed when tab is active)
struct TransactionListView: View {
    let ticker: String
    @ObservedObject var transactionVM: TransactionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trade History")
                .font(.headline)
                .padding(.bottom, 5)

            if transactionVM.isLoading {
                ProgressView("Loading transactions...")
                    .frame(maxWidth: .infinity)
            } else if let error = transactionVM.error {
                Text("Failed to load transactions: \(error)")
                    .foregroundColor(.red)
            } else if transactionVM.transactions.isEmpty {
                Text("No trading history found for \(ticker).")
                    .foregroundColor(.secondary)
            } else {
                ForEach(transactionVM.transactions) { transaction in
                    VStack(spacing: 0) {
                        TransactionRow(transaction: transaction)
                        Divider()
                            .background(Color.secondary.opacity(0.1))
                    }
                }
            }
        }
    }
}

// NEW: Single Transaction Row View
struct TransactionRow: View {
    let transaction: StockTransaction
    
    // Date formatter for display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Type and Quantity
                Text("\(transaction.transactionType) \(String(format: "%.2f", transaction.quantity)) Shares")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    // Color based on type
                    .foregroundColor(transaction.transactionType.uppercased() == "BUY" ? .green : .red)
                
                // Date
                Text(dateFormatter.string(from: transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Total Cash Delta (e.g., total cost/proceeds)
                Text(transaction.cashDelta, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                // Price per share
                Text(String(format: "@ $%.2f", transaction.price))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}


struct OneYearPriceChart: View {
    let symbol: String
    @StateObject private var vm = OneYearChartViewModel() // Assuming this is defined

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
                    if let pct = vm.pctReturn1Y { // Assuming pctReturn1Y is defined
                        LineMark(
                            x: .value("Date", p.dateValue), // Assuming dateValue is defined
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
                .chartYAxis(.hidden)      // ⛔ Hide Y axis and gridlines
                .chartXAxis(.hidden)      // ⛔ Hide X axis and gridlines
                .chartPlotStyle { plot in // ⛔ Transparent plot background
                    plot.background(.clear)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 240)
            }
        }
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
                                .fill(selected == tf ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
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
                                .fill(i == selectedIndex ? Color.white.opacity(0.15) : Color.white.opacity(0.0))
                        )
                        .overlay(
                            Capsule()
                                .stroke(i == selectedIndex ? Color.white.opacity(0.35) : Color.white.opacity(0.0), lineWidth: 1)
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
