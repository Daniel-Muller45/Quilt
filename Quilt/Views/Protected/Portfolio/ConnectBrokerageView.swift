import SwiftUI
import SwiftData

struct ConnectBrokerageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var vm = ConnectBrokerageViewModel()
    @StateObject private var portfolioVM = PortfolioViewModel()

    /// Pass the user’s bearer token from your auth layer
    let token: String
    /// Custom URL scheme you registered in Info.plist and set in SnapTrade (e.g., "quilt")
    let callbackScheme: String = "quilt"

    struct Brokerage: Identifiable {
        let id = UUID()
        let name: String
        let logoName: String
        let slug: String      // backend/SnapTrade slug (often uppercase like ROBINHOOD)
    }

    private let brokerages: [Brokerage] = [
        .init(name: "Robinhood",       logoName: "RobinhoodLogo",  slug: "ROBINHOOD"),
        .init(name: "Fidelity",        logoName: "FidelityLogo",   slug: "FIDELITY"),
        .init(name: "Chase",           logoName: "ChaseLogo",      slug: "CHASE"),
        .init(name: "Webull",          logoName: "WebullLogo",     slug: "WEBULL"),
        .init(name: "Charles Schwab",  logoName: "SchwabLogo",     slug: "SCHWAB"),
        .init(name: "Coinbase",        logoName: "CoinbaseLogo",   slug: "COINBASE"),
        .init(name: "E*TRADE",         logoName: "ETradeLogo",     slug: "ETRADE"),
        .init(name: "Wells Fargo",     logoName: "WellsFargoLogo", slug: "WELLS_FARGO"),
        .init(name: "Binance",         logoName: "BinanceLogo",    slug: "BINANCE")
    ]

    @State private var showWebSheet = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Connect a Brokerage")
                    .font(.title2).bold()
                    .padding(.top, 24)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(brokerages) { b in
                            Button {
                                Task { await vm.startLink(brokerageSlug: b.slug, token: token) }
                            } label: {
                                HStack(spacing: 16) {
                                    Image(b.logoName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))

                                    Text(b.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                            }
                            .buttonStyle(.plain)

                            if b.id != brokerages.last?.id {
                                Divider().padding(.leading, 64)
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
            // Bind contexts once
            .task {
                vm.bind(modelContext: modelContext)
                portfolioVM.bind(modelContext: modelContext)
            }
            // Present WebView when redirect URL appears
            .onChange(of: vm.redirectURL) { url in
                showWebSheet = (url != nil)
            }
            .sheet(isPresented: $showWebSheet, onDismiss: {
                vm.clearRedirect()
            }) {
                if let url = vm.redirectURL {
                    WebAuthWebView(
                        startURL: url,
                        callbackScheme: callbackScheme
                    ) { _ in
                        // Callback hit (or you can also handle .onOpenURL globally).
                        showWebSheet = false
                        vm.clearRedirect()

                        // 🔁 Just refetch portfolio on callback:
                        Task { await portfolioVM.refreshAll(token: token) }
                    }
                    .ignoresSafeArea()
                }
            }
            // Loading overlay
            .overlay {
                if vm.isLinking {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView("Preparing redirect…")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            // Error alert
            .alert("Error", isPresented: .constant(vm.error != nil), actions: {
                Button("OK") { vm.error = nil }
            }, message: { Text(vm.error ?? "Unknown error") })
        }
    }
}
