import SwiftUI
import SwiftData

struct OnboardingConnectView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var vm = ConnectBrokerageViewModel()
    @StateObject private var portfolioVM = PortfolioViewModel()

    let token: String
    let callbackScheme: String = "quilt"

    struct Brokerage: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let logoName: String
        let slug: String
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
    @State private var searchText: String = ""

    private var filteredBrokerages: [Brokerage] {
        guard !searchText.isEmpty else { return brokerages }
        let query = searchText.lowercased()
        return brokerages.filter { $0.name.lowercased().contains(query) }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { vm.error != nil },
            set: { newValue in
                if !newValue {
                    vm.error = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
//            Text("Get Started by Connecting a Brokerage")
            VStack(alignment: .leading, spacing: 0) {
                

                ScrollView {
                    VStack(spacing: 0) {
                        if filteredBrokerages.isEmpty {
                            Text("No brokerages found")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(filteredBrokerages) { b in
                                Button {
                                    Task {
                                        await vm.startLink(brokerageSlug: b.slug, token: token)
                                    }
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

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(.plain)

                                if b != filteredBrokerages.last {
                                    Divider()
                                        .padding(.leading, 64)
                                }
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
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search brokerages")
            .task {
                vm.bind(modelContext: modelContext)
                portfolioVM.bind(modelContext: modelContext)
            }
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
                        showWebSheet = false
                        vm.clearRedirect()

                        Task { await portfolioVM.refreshAll(token: token) }
                    }
                    .ignoresSafeArea()
                }
            }
            .overlay {
                if vm.isLinking {
                    ZStack {
//                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView("Preparing redirect…")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .alert("Error", isPresented: isShowingError) {
                Button("OK", role: .cancel) {
                    vm.error = nil
                }
            } message: {
                Text(vm.error ?? "Unknown error")
            }
        }
    }
}
