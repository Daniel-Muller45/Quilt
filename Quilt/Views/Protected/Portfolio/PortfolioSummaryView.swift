import SwiftUI
import SwiftData

struct PortfolioSummaryView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @State private var selectedIndex: Int = 0
    @State private var showingConnectBrokerage = false
    @State private var selectedTimeframe: Timeframe = .d1
    private let timeframes = Timeframe.allCases
    
    let token: String

    // MARK: - Helper Struct for Display
    /// Normalizes data between a raw Holding and an Aggregated Holding for the list
    struct HoldingRowData: Identifiable {
        let id: String
        let symbol: String
        let quantity: Double
        let currentValue: Double
        let dayChangePercent: Double?
        let accountName: String?
        // We keep a reference to one of the underlying holdings to satisfy the PositionDetailView requirement.
        // Note: For aggregated rows, this links to the first holding found.
        let representativeHolding: Holding
    }

    private var totalCurrency: String {
        accounts.first?.currency ?? "USD"
    }
    
    private var totalCurrentValue: Double {
        accounts.reduce(0) { $0 + $1.currentValue }
    }
    
    private var totalDayChangePercent: Double? {
        guard !accounts.isEmpty, accounts.allSatisfy({ $0.dayChangePercent != nil }) else { return nil }
        let total = totalCurrentValue
        guard total > 0 else { return 0 }
        let weighted = accounts.reduce(0.0) { sum, a in
            sum + (a.currentValue * (a.dayChangePercent ?? 0) / 100.0)
        }
        return (weighted / total) * 100.0
    }

    private var selectedIsTotal: Bool { selectedIndex == 0 }
    
    private var selectedAccount: Account? {
        guard selectedIndex > 0, selectedIndex - 1 < accounts.count else { return nil }
        return accounts[selectedIndex - 1]
    }
    
    // MARK: - Aggregation Logic
    private var holdingsToShow: [HoldingRowData] {
        if selectedIsTotal {
            // 1. Get all holdings from all accounts
            let allHoldings = accounts.flatMap { $0.holdings }
            
            // 2. Group by symbol
            let grouped = Dictionary(grouping: allHoldings) { $0.symbol }
            
            // 3. Aggregate
            let aggregated = grouped.map { symbol, holdings -> HoldingRowData in
                let totalQty = holdings.reduce(0) { $0 + $1.quantity }
                let totalVal = holdings.reduce(0) { $0 + $1.currentValue }
                
                // Calculate weighted average for day change %
                // (Value * Pct) / TotalValue
                var weightedSum = 0.0
                if totalVal > 0 {
                    weightedSum = holdings.reduce(0.0) { sum, h in
                        sum + (h.currentValue * (h.dayChangePercent ?? 0))
                    }
                }
                let avgPct = totalVal > 0 ? (weightedSum / totalVal) : 0.0
                
                // Use the first holding to satisfy NavigationLink requirements
                let firstHolding = holdings.first!
                
                return HoldingRowData(
                    id: "AGG_\(symbol)", // Unique ID for the list
                    symbol: symbol,
                    quantity: totalQty,
                    currentValue: totalVal,
                    dayChangePercent: avgPct,
                    accountName: nil, // No account name for combined view
                    representativeHolding: firstHolding
                )
            }
            
            // 4. Sort
            return aggregated.sorted {
                if $0.currentValue == $1.currentValue {
                    return $0.symbol < $1.symbol
                }
                return $0.currentValue > $1.currentValue
            }
            
        } else {
            // Single Account Mode
            guard let account = selectedAccount else { return [] }
            
            let sortedHoldings = account.holdings.sorted {
                if $0.currentValue == $1.currentValue {
                    return $0.symbol < $1.symbol
                }
                return $0.currentValue > $1.currentValue
            }
            
            // Map directly to RowData
            return sortedHoldings.map { h in
                HoldingRowData(
                    id: String(describing: h.id),
                    symbol: h.symbol,
                    quantity: h.quantity,
                    currentValue: h.currentValue,
                    dayChangePercent: h.dayChangePercent,
                    accountName: nil, // We are inside a specific account tab, usually redundant to show name, but can add `account.name` if desired. User requested "not show" for total list.
                    representativeHolding: h
                )
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(
                title: "Portfolio",
                token: token
            )

            ScrollView {
                if accounts.isEmpty {
                    VStack(spacing: 12) {
                        Text("No accounts yet").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    VStack(spacing: 12) {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    tabButton(title: "Total", index: 0)
                                        .id(0)
                                    
                                    ForEach(Array(accounts.enumerated()), id: \.offset) { offset, account in
                                        let index = offset + 1
                                        tabButton(title: account.name, index: index)
                                            .id(index)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: selectedIndex) { newValue in
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(newValue, anchor: .center)
                                }
                            }
                            .onAppear {
                                proxy.scrollTo(selectedIndex, anchor: .center)
                            }
                        }
                    }
                    
                    TabView(selection: $selectedIndex) {
                        totalCard
                            .padding(.horizontal)
                            .tag(0)
                        
                        ForEach(Array(accounts.enumerated()), id: \.offset) { offset, account in
                            let index = offset + 1
                            accountCard(account: account, isSelected: selectedIndex == index)
                                .padding(.horizontal)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 270)
                    
                    timeframePicker
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Holdings")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            Button {
                                // TODO: show filter sheet or sort options
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.trailing)
                        }
                        .padding()
                        
                        // Loop over our new HoldingRowData
                        ForEach(Array(holdingsToShow.enumerated()), id: \.element.id) { index, h in
                            NavigationLink(destination: PositionDetailView(holding: h.representativeHolding)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(h.symbol).font(.headline)
                                        Text("\(h.quantity, specifier: "%.2f") shares")
                                            .font(.subheadline).foregroundColor(.secondary)
                                        
                                        // Only show account name if it exists (it is nil in Total view)
                                        if let acctName = h.accountName {
                                            Text(acctName)
                                                .font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        let currency = selectedIsTotal
                                        ? totalCurrency
                                        : (selectedAccount?.currency ?? "USD")
                                        
                                        Text(h.currentValue, format: .currency(code: currency))
                                            .fontWeight(.semibold)
                                        
                                        if let pct = h.dayChangePercent {
                                            Text(String(format: "%+.2f%%", pct))
                                                .font(.subheadline).fontWeight(.semibold)
                                                .foregroundColor(pct >= 0 ? .green : .red)
                                        } else {
                                            Text("—").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal) // Moved padding here for better list alignment
                            
                            // Add separator line between items, but not after the last one
                            if index < holdingsToShow.count - 1 {
                                Divider()
                                    .padding(.horizontal, 32) // Indented slightly more than the cards
                            }
                        }
                    }
                }
                .padding(.vertical)
                .sheet(isPresented: $showingConnectBrokerage) {
                    ConnectBrokerageView(token: token)
                }
            }
        }
        .onAppear {
            if selectedIndex >= accounts.count + 1 { selectedIndex = 0 }
        }
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        let isSelected = selectedIndex == index
        return Button {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.prepare()
            withAnimation(.easeInOut) { selectedIndex = index }
            gen.impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15,
                                  weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                Capsule()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    private var totalCard: some View {
        return VStack(alignment: .leading, spacing: 12) {
            PortfolioHistoryChartView(selectedTimeframe: $selectedTimeframe)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func accountCard(account: Account, isSelected: Bool) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            PortfolioHistoryChartView(selectedTimeframe: $selectedTimeframe)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeframePicker: some View {
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
                                      ? Color.secondary.opacity(0.3) // Adjusted for visibility
                                      : Color.clear)
                        )
                        .foregroundColor(selectedTimeframe == tf ? .primary : .secondary)
                }
            }
            Spacer()
        }
    }
}
