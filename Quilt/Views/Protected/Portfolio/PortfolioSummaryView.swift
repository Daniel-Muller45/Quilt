import SwiftUI
import SwiftData

struct PortfolioSummaryView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @State private var selectedIndex: Int = 0
    @State private var showingConnectBrokerage = false
    @State private var selectedTimeframe: Timeframe = .d1
    private let timeframes = Timeframe.allCases
    
    @State private var sortOption: SortOption = .value
    @State private var sortAscending: Bool = false
    
    enum SortOption: String, CaseIterable, Identifiable {
        case value = "Total Value"
        case totalReturn = "Total Return"
        case dayPercent = "Today's % Change"
        case totalPercent = "Total % Change"
        
        var id: String { rawValue }
    }
    
    let token: String

    struct HoldingRowData: Identifiable {
        let id: String
        let symbol: String
        let quantity: Double
        let currentValue: Double
        let totalCost: Double
        let dayChangePercent: Double?
        let accountName: String?
        let representativeHolding: Holding
        var totalReturn: Double { currentValue - totalCost }
        var totalReturnPercent: Double { totalCost != 0 ? (currentValue - totalCost) / totalCost : 0 }
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
    
    private var holdingsToShow: [HoldingRowData] {
        var data: [HoldingRowData] = []
        
        if selectedIsTotal {
            let allHoldings = accounts.flatMap { $0.holdings }
            
            let grouped = Dictionary(grouping: allHoldings) { $0.symbol }
            
            data = grouped.map { symbol, holdings -> HoldingRowData in
                let totalQty = holdings.reduce(0) { $0 + $1.quantity }
                let totalVal = holdings.reduce(0) { $0 + $1.currentValue }
                let totalCost = holdings.reduce(0) { $0 + ($1.avgCost * $1.quantity) }
                var weightedSum = 0.0
                if totalVal > 0 {
                    weightedSum = holdings.reduce(0.0) { sum, h in
                        sum + (h.currentValue * (h.dayChangePercent ?? 0))
                    }
                }
                let avgPct = totalVal > 0 ? (weightedSum / totalVal) : 0.0
                
                let firstHolding = holdings.first!
                
                return HoldingRowData(
                    id: "AGG_\(symbol)",
                    symbol: symbol,
                    quantity: totalQty,
                    currentValue: totalVal,
                    totalCost: totalCost,
                    dayChangePercent: avgPct,
                    accountName: nil,
                    representativeHolding: firstHolding
                )
            }
        } else {
            guard let account = selectedAccount else { return [] }
            
            data = account.holdings.map { h in
                HoldingRowData(
                    id: String(describing: h.id),
                    symbol: h.symbol,
                    quantity: h.quantity,
                    currentValue: h.currentValue,
                    totalCost: h.avgCost * h.quantity,
                    dayChangePercent: h.dayChangePercent,
                    accountName: nil,
                    representativeHolding: h
                )
            }
        }
        
        return data.sorted { a, b in
            let isAsc = sortAscending
            switch sortOption {
            case .value:
                return isAsc ? a.currentValue < b.currentValue : a.currentValue > b.currentValue
            case .totalReturn:
                return isAsc ? a.totalReturn < b.totalReturn : a.totalReturn > b.totalReturn
            case .totalPercent:
                return isAsc ? a.totalReturnPercent < b.totalReturnPercent : a.totalReturnPercent > b.totalReturnPercent
            case .dayPercent:
                let pA = a.dayChangePercent ?? -999
                let pB = b.dayChangePercent ?? -999
                return isAsc ? pA < pB : pA > pB
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(
                title: "Portfolio",
                token: token
            )
            
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
                .padding(.bottom)
                
                ScrollView {
                    VStack(spacing: 12) {
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
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("Holdings")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Section("Sort By") {
                                            ForEach(SortOption.allCases) { option in
                                                Button {
                                                    withAnimation { sortOption = option }
                                                } label: {
                                                    if sortOption == option {
                                                        Label(option.rawValue, systemImage: "checkmark")
                                                    } else {
                                                        Text(option.rawValue)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Section("Order") {
                                            Button {
                                                withAnimation { sortAscending = false }
                                            } label: {
                                                if !sortAscending {
                                                    Label("Highest First", systemImage: "checkmark")
                                                } else {
                                                    Text("Highest First")
                                                }
                                            }
                                            Button {
                                                withAnimation { sortAscending = true }
                                            } label: {
                                                if sortAscending {
                                                    Label("Lowest First", systemImage: "checkmark")
                                                } else {
                                                    Text("Lowest First")
                                                }
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.trailing)
                                }
                                .padding()
                                
                                ForEach(Array(holdingsToShow.enumerated()), id: \.element.id) { index, h in
                                    NavigationLink(destination: PositionDetailView(holding: h.representativeHolding)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(h.symbol).font(.headline)
                                                Text("\(h.quantity, specifier: "%.2f") shares")
                                                    .font(.subheadline).foregroundColor(.secondary)
                                                
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
                                                
                                                Group {
                                                    switch sortOption {
                                                    case .totalReturn:
                                                        Text(h.totalReturn, format: .currency(code: currency).sign(strategy: .always()))
                                                    case .totalPercent:
                                                        Text(String(format: "%+.2f%%", h.totalReturnPercent * 100))
                                                    default:
                                                        if let pct = h.dayChangePercent {
                                                            Text(String(format: "%+.2f%%", pct))
                                                        } else {
                                                            Text("—")
                                                        }
                                                    }
                                                }
                                                .font(.subheadline).fontWeight(.semibold)
                                                .foregroundColor({
                                                    switch sortOption {
                                                    case .totalReturn, .totalPercent:
                                                        return h.totalReturn >= 0 ? .green : .red
                                                    default:
                                                        return (h.dayChangePercent ?? 0) >= 0 ? .green : .red
                                                    }
                                                }())
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                    
                                    if index < holdingsToShow.count - 1 {
                                        Divider()
                                            .padding(.horizontal, 32)
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
            PortfolioHistoryChartView(selectedTimeframe: $selectedTimeframe, liveCurrentValue: totalCurrentValue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func accountCard(account: Account, isSelected: Bool) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            PortfolioHistoryChartView(selectedTimeframe: $selectedTimeframe, liveCurrentValue: account.currentValue)
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
                                      ? Color.secondary.opacity(0.3)
                                      : Color.clear)
                        )
                        .foregroundColor(selectedTimeframe == tf ? .primary : .secondary)
                }
            }
            Spacer()
        }
    }
}
