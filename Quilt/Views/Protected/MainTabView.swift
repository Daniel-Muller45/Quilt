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

//            NewsScreen(token: authViewModel.session?.accessToken ?? "")
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
//                .tag(2)
            PortfolioAnalysisView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(2)
//            OnboardingView()
//                .tabItem {
//                    Label("Onb", systemImage: "newspaper.fill")
//                }
//                .tag(3)
//            
//            PortfolioAnalysisView()
//                .tabItem {
//                    Label("Onb", systemImage: "newspaper.fill")
//                }
//                .tag(4)
        }
        .accentColor(.white)
    }
}
