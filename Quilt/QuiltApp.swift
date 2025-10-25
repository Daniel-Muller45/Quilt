import SwiftUI

@main
struct QuiltApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
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

                if authViewModel.isLocked {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            Text("Unlock with Face ID")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .onAppear {
                        Task { await authViewModel.unlockApp() }
                    }
                }

            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    authViewModel.lockApp()
                case .active:
                    if authViewModel.isLocked {
                        Task { await authViewModel.unlockApp() }
                    }
                default:
                    break
                }
            }
        }
    }
}
