import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        TabView {
//            PortfolioView()
//                .tabItem {
//                    Label("Portfolio", systemImage: "chart.pie.fill")
//                }
//            NewsView()
//                .tabItem {
//                    Label("News", systemImage: "newspaper.fill")
//                }
            
        
            PortfolioScreen(token: authViewModel.session?.accessToken ?? "")
                    .tabItem {
                        Label("Portfolio", systemImage: "chart.pie.fill")
                    }
            NewsScreen()
                    .tabItem {
                        Label("News", systemImage: "chart.pie.fill")
                    }
//            SettingsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape.fill")
//                }
        }
    }
}
