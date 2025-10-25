import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Temporary mock data
    @State private var totalPortfolios: [Portfolio] = [
        Portfolio(name: "Total Portfolio", value: 152430.87),
        Portfolio(name: "Robinhood", value: 65230.55),
        Portfolio(name: "Charles Schwab", value: 87200.32)
    ]
    
    @State private var accounts: [Account] = [
        Account(name: "SPY", balance: 74210.32),
        Account(name: "TSLA", balance: 58420.55),
        Account(name: "META", balance: 19800.00)
    ]

    @State private var showingConnectBrokerage = false // controls the sheet

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // --- Horizontal Swipe Cards ---
                    TabView {
                        ForEach(totalPortfolios) { portfolio in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(portfolio.name)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(portfolio.value.formatted(.currency(code: "USD")))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                        }
                    }
                    .frame(height: 140)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    // --- Accounts Section ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Holdings")
                            .font(.headline)

                        ForEach(accounts) { account in
                            HStack {
                                Text(account.name)
                                    .font(.body)
                                Spacer()
                                Text(account.balance.formatted(.currency(code: "USD")))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingConnectBrokerage.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingConnectBrokerage) {
                ConnectBrokerageView()
            }
        }
    }
}

// Temporary models
struct Portfolio: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
}

struct Account: Identifiable {
    let id = UUID()
    let name: String
    let balance: Double
}

#Preview {
    PortfolioView()
        .environmentObject(AuthViewModel())
}
