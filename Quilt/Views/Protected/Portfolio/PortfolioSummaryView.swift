import SwiftUI
import SwiftData

struct PortfolioSummaryView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @State private var selectedIndex: Int = 0   // 0 = Total, 1... = accounts[index-1]
    @State private var showingConnectBrokerage = false
    
    let token: String

    // MARK: - Totals
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

    // MARK: - Derived selection
    private var selectedIsTotal: Bool { selectedIndex == 0 }
    private var selectedAccount: Account? {
        guard selectedIndex > 0, selectedIndex - 1 < accounts.count else { return nil }
        return accounts[selectedIndex - 1]
    }
    private var holdingsToShow: [Holding] {
        let sortByValue: (Holding, Holding) -> Bool = { a, b in
            if a.currentValue == b.currentValue {
                return a.symbol < b.symbol
            } else {
                return a.currentValue > b.currentValue   // DESC by market value
            }
        }
        if selectedIsTotal {
            return accounts.flatMap { $0.holdings }.sorted(by: sortByValue)
        } else {
            return (selectedAccount?.holdings.sorted(by: sortByValue)) ?? []
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Portfolios")
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
                Button { showingConnectBrokerage.toggle() } label: {
                    Image(systemName: "plus").imageScale(.large)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            HStack {
                Text(Date.now.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary)
                    .padding()
                Spacer()
            }

            if accounts.isEmpty {
                VStack(spacing: 12) {
                    Text("No accounts yet").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // MARK: Horizontal cards (Total + Accounts)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        // Total card (index 0)
                        totalCard
                            .padding(.horizontal, 12)

                        // Account cards (indices 1...N)
                        ForEach(0..<accounts.count, id: \.self) { i in
                            let index = i + 1
                            let account = accounts[i]
                            accountCard(account: account, isSelected: selectedIndex == index)
                                .padding(.horizontal, 12)
                                .onTapGesture {
                                    let gen = UIImpactFeedbackGenerator(style: .medium)
                                    gen.prepare()
                                    withAnimation(.easeInOut) { selectedIndex = index }
                                    gen.impactOccurred()
                                }
                        }
                    }
                }

                // MARK: Holdings list (for selected card)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedIsTotal ? "All Holdings" : "Holdings")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(holdingsToShow) { h in
                                NavigationLink(destination: PositionDetailView(holding: h)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(h.symbol).font(.headline)
                                            Text("\(h.quantity, specifier: "%.2f") shares")
                                                .font(.subheadline).foregroundColor(.secondary)
                                            if selectedIsTotal, let acctName = h.account?.name {
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
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    // trigger your sync
                }
                .sheet(isPresented: $showingConnectBrokerage) {
                    ConnectBrokerageView(token: token)
                }
            }
        }
        .onAppear {
            if selectedIndex >= accounts.count + 1 { selectedIndex = 0 }
        }
    }

    // MARK: - Card Views

    private var totalCard: some View {
        let isSelected = selectedIndex == 0
        return VStack(alignment: .leading, spacing: 8) {
            Text("Total").font(.headline)
            Text(totalCurrentValue, format: .currency(code: totalCurrency))
                .font(.system(size: 28, weight: .bold))
            if let pct = totalDayChangePercent {
                Text(String(format: "%+.2f%%", pct))
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(pct >= 0 ? .green : .red)
            } else {
                Text("—").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1.5)
        )
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.prepare()
            withAnimation(.easeInOut) { selectedIndex = 0 }
            gen.impactOccurred()
        }
    }

    private func accountCard(account: Account, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name).font(.headline)
            Text(account.currentValue, format: .currency(code: account.currency))
                .font(.system(size: 28, weight: .bold))
            if let pct = account.dayChangePercent {
                Text(String(format: "%+.2f%%", pct))
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(pct >= 0 ? .green : .red)
            } else {
                Text("—").font(.subheadline).fontWeight(.semibold).foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1.5)
        )
        .cornerRadius(12)
    }
}
