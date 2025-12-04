import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {

            AnalysisScreen(token: authViewModel.session?.accessToken ?? "")
                .tabItem {
                    Label("Analysis", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)
            PortfolioScreen(token: authViewModel.session?.accessToken ?? "")
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
                .tag(1)
            PortfolioAnalysisView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(2)
        }
        .accentColor(.white)
    }
}
