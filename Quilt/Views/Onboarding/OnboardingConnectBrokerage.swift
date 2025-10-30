import SwiftUI

struct OnboardingConnectBrokerageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @StateObject private var brokerageViewModel = BrokerageViewModel()

    var onConnected: () -> Void

    @State private var isLoading = false
    @State private var error: String?

    struct Brokerage: Identifiable {
        let id = UUID()
        let name: String
        let logoName: String
        let slug: String   // e.g., "robinhood", "fidelity"
    }

    // Brokerages list
    let brokerages: [Brokerage] = [
        Brokerage(name: "Robinhood", logoName: "RobinhoodLogo", slug: "robinhood"),
        Brokerage(name: "Fidelity", logoName: "FidelityLogo", slug: "fidelity"),
        Brokerage(name: "Chase", logoName: "ChaseLogo", slug: "chase"),
        Brokerage(name: "Webull", logoName: "WebullLogo", slug: "webull"),
        Brokerage(name: "Charles Schwab", logoName: "SchwabLogo", slug: "charles_schwab"),
        Brokerage(name: "Coinbase", logoName: "CoinbaseLogo", slug: "coinbase"),
        Brokerage(name: "ETrade", logoName: "ETradeLogo", slug: "etrade"),
        Brokerage(name: "Wells Fargo", logoName: "WellsFargoLogo", slug: "wells_fargo"),
        Brokerage(name: "Binance", logoName: "BinanceLogo", slug: "binance")
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Connect a Brokerage")
                    .font(.title2.bold())
                    .padding(.top, 24)
                    .padding(.horizontal)

                if isLoading {
                    Spacer()
                    ProgressView("Connecting…")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(brokerages) { brokerage in
                                Button {
                                    connectAndRedirect(brokerage)
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(brokerage.logoName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))

                                        Text(brokerage.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(.plain)

                                if brokerage.id != brokerages.last?.id {
                                    Divider().padding(.leading, 64)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .navigationTitle("Connect Brokerage")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Connect + Redirect Logic
    func connectAndRedirect(_ brokerage: Brokerage) {
        guard let tempData = LocalStorage.loadBrokerageData() else {
            error = "No temporary user found. Please restart onboarding."
            return
        }

        isLoading = true
        error = nil

        // 🔹 Fetch the redirect URL via your backend
        brokerageViewModel.getLoginRedirect(
            userId: tempData.userId,
            userSecret: tempData.userSecret,
            brokerage: brokerage.slug,
            token: "" // no Supabase token yet for public flow
        )

        // 🔹 Observe when redirectURL updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            if let redirectURL = brokerageViewModel.redirectURL,
               let url = URL(string: redirectURL) {
                // Open in Safari to complete connection
                UIApplication.shared.open(url)
                onConnected()
            } else if let err = brokerageViewModel.errorMessage {
                error = err
            } else {
                error = "Failed to get redirect URL."
            }
        }
    }
}
