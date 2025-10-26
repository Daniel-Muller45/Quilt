import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
            
        
//            ProfileView()
//                .tabItem {
//                    Label("Profile", systemImage: "person.crop.circle")
//                }
//
//            SettingsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape.fill")
//                }
        }
    }
}
