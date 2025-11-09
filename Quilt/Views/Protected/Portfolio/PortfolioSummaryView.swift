import SwiftUI
import SwiftData

struct PortfolioSummaryView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @State private var selectedAccountIndex: Int = 0
    @State private var showingConnectBrokerage = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Portfolios")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 20) {
                    Button {
                        showingConnectBrokerage.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            HStack {
                Text(Date.now.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            }

            if accounts.isEmpty {
                VStack(spacing: 12) {
                    Text("No accounts yet").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Horizontal account cards (OK to keep horizontal scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(accounts.indices, id: \.self) { index in
                            let account = accounts[index]
                            let balance = account.currentValue  // uses your extension
                            VStack(alignment: .leading, spacing: 8) {
                                Text(account.name).font(.headline)
                                Text(balance, format: .currency(code: account.currency))
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
                                    .fill(selectedAccountIndex == index ? Color.blue.opacity(0.15) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedAccountIndex == index ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 12)
                            .onTapGesture {
                                let gen = UIImpactFeedbackGenerator(style: .medium)
                                gen.prepare()
                                withAnimation(.easeInOut) { selectedAccountIndex = index }
                                gen.impactOccurred()
                            }
                        }
                    }
                }

                // Holdings list (the ONLY vertical ScrollView) + refreshable here
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Holdings")
                                .font(.headline)
                                .padding(.horizontal)

                            let account = accounts[min(selectedAccountIndex, accounts.count - 1)]
                            ForEach(account.holdings.sorted(by: { $0.symbol < $1.symbol })) { h in
                                NavigationLink(destination: PositionDetailView(holding: h)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(h.symbol).font(.headline)
                                            Text("\(h.quantity, specifier: "%.2f") shares")
                                                .font(.subheadline).foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(h.currentValue, format: .currency(code: account.currency))
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
                    // Call back to the parent; ensure this hits the *bound* VM
                }
                .sheet(isPresented: $showingConnectBrokerage) {
                    ConnectBrokerageView()
                }
            }
        }
    }
}
