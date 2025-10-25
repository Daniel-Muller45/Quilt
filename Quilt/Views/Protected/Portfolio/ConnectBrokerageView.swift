import SwiftUI

struct ConnectBrokerageView: View {
    @Environment(\.dismiss) var dismiss

    // Brokerage model
    struct Brokerage: Identifiable {
        let id = UUID()
        let name: String
        let logoName: String  // name of image asset
    }

    // Brokerages list
    let brokerages: [Brokerage] = [
        Brokerage(name: "Robinhood", logoName: "RobinhoodLogo"),
        Brokerage(name: "Fidelity", logoName: "FidelityLogo"),
        Brokerage(name: "Chase", logoName: "ChaseLogo"),
        Brokerage(name: "Webull", logoName: "WebullLogo"),
        Brokerage(name: "Charles Schwab", logoName: "SchwabLogo"),
        Brokerage(name: "Coinbase", logoName: "CoinbaseLogo"),
        Brokerage(name: "ETrade", logoName: "ETradeLogo"),
        Brokerage(name: "Wells Fargo", logoName: "WellsFargoLogo"),
        Brokerage(name: "Binance", logoName: "BinanceLogo")
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Connect a Brokerage")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 24)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(brokerages) { brokerage in
                            Button {
                                // TODO: Connect logic here later
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

                            // Divider below each item except the last
                            if brokerage.id != brokerages.last?.id {
                                Divider()
                                    .padding(.leading, 64) // align under text, not logo
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
