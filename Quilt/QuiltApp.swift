import SwiftUI

@main
struct QuiltApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoading {
                LoadingView()
                    .preferredColorScheme(.dark)
            } else {
                ProtectedView {
                    MainTabView()
                }
                .environmentObject(authViewModel)
                .preferredColorScheme(.dark)
            }
        }
    }
}
