import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {

            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "arrow.up.arrow.down")
                }
                .tag(0)

            PortfolioScreen(token: authViewModel.session?.accessToken ?? "")
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
                .tag(1)

            NewsScreen()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(2)
        }
        .accentColor(.white)
    }
}
