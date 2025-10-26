import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Mock data
    @State private var accounts: [Account] = [
        Account(
            name: "Total",
            balance: 152430.87,
            change: 1.37,
            positions: [
                Position(symbol: "MSFT", shares: 15, value: 5400.00, change: 0.45),
                Position(symbol: "AAPL", shares: 25, value: 4550.00, change: 1.25),
                Position(symbol: "SPY", shares: 25, value: 4550.00, change: 1.25),
                Position(symbol: "NVDA", shares: 5, value: 2900.00, change: 2.11),
                Position(symbol: "TSLA", shares: 10, value: 2400.00, change: -0.75),
                Position(symbol: "MSFT", shares: 15, value: 5400.00, change: 0.45),
                Position(symbol: "AAPL", shares: 25, value: 4550.00, change: 1.25),
                Position(symbol: "SPY", shares: 25, value: 4550.00, change: 1.25),
                Position(symbol: "NVDA", shares: 5, value: 2900.00, change: 2.11),
                Position(symbol: "TSLA", shares: 10, value: 2400.00, change: -0.75)
            ]
        ),
        Account(
            name: "Robinhood Individual",
            balance: 65230.55,
            change: -0.89,
            positions: [
                Position(symbol: "AAPL", shares: 25, value: 4550.00, change: 1.25),
                Position(symbol: "TSLA", shares: 10, value: 2400.00, change: -0.75)
            ]
        ),
        Account(
            name: "Robinhood Roth IRA",
            balance: 15230.55,
            change: -0.89,
            positions: [
                Position(symbol: "SPY", shares: 25, value: 4550.00, change: 1.25),
            ]
        ),
        Account(
            name: "Charles Schwab",
            balance: 87200.32,
            change: 0.15,
            positions: [
                Position(symbol: "MSFT", shares: 15, value: 5400.00, change: 0.45),
                Position(symbol: "NVDA", shares: 5, value: 2900.00, change: 2.11)
            ]
        )
    ]

    @State private var showingConnectBrokerage = false
    @State private var signOutAlert = false
    @State private var selectedAccountIndex = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
//                        Button {
//                            signOutAlert = true
//                        } label: {
//                            Image(systemName: "rectangle.portrait.and.arrow.right")
//                                .imageScale(.large)
//                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12) // top safe area spacing
                .padding(.bottom, 8)
//                .background(.ultraThinMaterial) // optional for glassy header look

                // Date label below header
                HStack {
                    Text(Date.now.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(accounts.indices, id: \.self) { index in
                            let account = accounts[index]
                            VStack(alignment: .leading, spacing: 8) {
                                Text(account.name)
                                    .font(.headline)
                                Text(account.balance.formatted(.currency(code: "USD")))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(String(format: "%+.2f%%", account.change))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(account.change >= 0 ? .green : .red)
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
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare() // primes the Taptic Engine
                                withAnimation(.easeInOut) {
                                    selectedAccountIndex = index
                                }
                                generator.impactOccurred() // trigger after state change
                            }
                        }
                    }
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Holdings list
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Holdings")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(accounts[selectedAccountIndex].positions) { position in
                                NavigationLink(destination: PositionDetailView(position: position)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(position.symbol)
                                                .font(.headline)
                                            Text(String(format: "%.2f shares", position.shares))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(position.value.formatted(.currency(code: "USD")))
                                                .fontWeight(.semibold)
                                            Text(String(format: "%+.2f%%", position.change))
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(position.change >= 0 ? .green : .red)
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
//                .navigationTitle("Portfolios")
//                .toolbar {
//                    ToolbarItemGroup(placement: .navigationBarTrailing) {
//                        Button(action: { showingConnectBrokerage.toggle() }) {
//                            Image(systemName: "plus")
//                                .imageScale(.large)
//                                .padding(.top, 2)
//                        }
//
//                        Button {
//                            signOutAlert = true
//                        } label: {
//                            Image(systemName: "rectangle.portrait.and.arrow.right")
//                                .imageScale(.large)
//                                .padding(.top, 2)
//                        }
//                    }
//                }

                .alert("Sign out?", isPresented: $signOutAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Sign Out", role: .destructive) {
                        Task { await authViewModel.signOut() }
                    }
                } message: {
                    Text("You will be logged out of your account.")
                }
                .sheet(isPresented: $showingConnectBrokerage) {
                    ConnectBrokerageView()
                }
                
            }
        }
    }
}

// MARK: - Models
struct Account: Identifiable {
    let id = UUID()
    let name: String
    let balance: Double
    let change: Double
    let positions: [Position]
}

struct Position: Identifiable {
    let id = UUID()
    let symbol: String
    let shares: Double
    let value: Double
    let change: Double
}


#Preview {
    PortfolioView()
        .environmentObject(AuthViewModel())
}
