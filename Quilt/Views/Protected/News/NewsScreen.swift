import SwiftUI

// MARK: - Models

enum BrokerageTab: String, CaseIterable, Identifiable {
    case total = "Total"
    case robinhood = "Robinhood"
    case vanguard = "Vanguard"
    case schwab = "Charles Schwab"
    case fidelity = "Fildelity"

    var id: String { rawValue }
}

struct HoldingSample: Identifiable {
    let id = UUID()
    let symbol: String
    let shares: Double
    let accountName: String
    let value: Double
    let pctChange: Double
}

// Dummy data
let sampleHoldings: [HoldingSample] = [
    .init(symbol: "SPY",  shares: 21.35, accountName: "Fidelity", value: 14590.16, pctChange: 0.06),
    .init(symbol: "PLTR", shares: 21.35, accountName: "Fidelity", value: 3932.03, pctChange: -3.56),
    .init(symbol: "SPY",  shares: 2.51,  accountName: "Robinhood", value: 1715.28, pctChange: 0.06),
    .init(symbol: "META", shares: 1.97,  accountName: "Robinhood", value: 1199.75, pctChange: -2.88)
]

// MARK: - Screen

struct NewsScreen: View {
    @State private var selectedTab: BrokerageTab = .total
    @State private var selectedTimeframe: String = "1D"

    private let timeframes = ["1D", "1W", "6M", "YTD", "1Y", "5Y"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // TOP SECTION: Tabs + Swipable pages
                VStack(alignment: .leading, spacing: 16) {
                    headerTabs

                    pagerSection

                    timeframePicker
                }
                .padding(.top, 16)
                .padding(.horizontal)

                Divider()
                    .background(Color.gray.opacity(0.4))

                // BOTTOM SECTION: Holdings list (scrolls vertically)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Holdings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(sampleHoldings) { holding in
                            HoldingRow(holding: holding)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 12)
                }
            }
        }
    }

    // MARK: Header tabs (Total / Robinhood / ...)

    private var headerTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(BrokerageTab.allCases) { tab in
                    VStack(spacing: 4) {
                        Button {
                            withAnimation(.spring()) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 15,
                                              weight: tab == selectedTab ? .semibold : .regular))
                                .foregroundColor(tab == selectedTab ? .white : .gray)
                        }
                        
                        Capsule()
                            .fill(tab == selectedTab ? Color.white : Color.clear)
                            .frame(height: 2)
                    }
                }
                
                Spacer()
            }
        }
    }

    // MARK: Swipable pager

    private var pagerSection: some View {
        TabView(selection: $selectedTab) {
            ForEach(BrokerageTab.allCases) { tab in
                BrokerageSummaryView(tab: tab)
                    .tag(tab)          // connects this page to selectedTab
                    .padding(.trailing, 16) // gives a bit of room on right edge
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // <- paging, no dots
        .frame(height: 230)
    }

    // MARK: Timeframe picker (1D, 1W, ...)

    private var timeframePicker: some View {
        HStack(spacing: 16) {
            ForEach(timeframes, id: \.self) { tf in
                Button {
                    withAnimation(.easeInOut) {
                        selectedTimeframe = tf
                    }
                } label: {
                    Text(tf)
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(selectedTimeframe == tf
                                      ? Color.white.opacity(0.15)
                                      : Color.clear)
                        )
                        .foregroundColor(selectedTimeframe == tf ? .white : .gray)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Subviews

/// Top summary + fake chart for each brokerage
struct BrokerageSummaryView: View {
    let tab: BrokerageTab

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // In your real app you'll bind to actual data for each brokerage
            Text("$18,608.70")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            Text("▲ $176.70 (0.95%) Today")
                .font(.subheadline)
                .foregroundColor(.green)

            Text("As of 10/13 9:49 am")
                .font(.caption)
                .foregroundColor(.gray)

            LineChartPlaceholder()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Simple “fake chart” so you can see the layout.
/// Replace with a real `Chart` later.
struct LineChartPlaceholder: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height

                path.move(to: CGPoint(x: 0, y: h * 0.7))
                path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.4))
                path.addLine(to: CGPoint(x: w * 0.3,  y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.5,  y: h * 0.3))
                path.addLine(to: CGPoint(x: w * 0.7,  y: h * 0.6))
                path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.5))
                path.addLine(to: CGPoint(x: w,       y: h * 0.2))
            }
            .stroke(lineWidth: 2)
            .foregroundColor(.green)
        }
    }
}

/// Row for a single holding
struct HoldingRow: View {
    let holding: HoldingSample

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(holding.symbol)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(holding.shares, specifier: "%.2f") shares")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(holding.accountName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(holding.value, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(.white)

                Text(String(format: "%+.2f%%", holding.pctChange))
                    .font(.subheadline)
                    .foregroundColor(holding.pctChange >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct NewsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewsScreen()
            .preferredColorScheme(.dark)
    }
}
