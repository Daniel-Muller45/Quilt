import SwiftUI

@main
struct QuiltApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                // MARK: - App States
                if authViewModel.isLoading {
                    // Loading while checking Supabase session
                    LoadingView()
                        .preferredColorScheme(.dark)
                } else if authViewModel.session == nil {
                    // Not signed in → show login screen
                    LoginView()
                        .environmentObject(authViewModel)
                        .preferredColorScheme(.dark)
                } else {
                    // Signed in → show main app
                    ProtectedView {
                        MainTabView()
                    }
                    .environmentObject(authViewModel)
                    .preferredColorScheme(.dark)
                }

                // MARK: - Lock Screen Overlay
                if authViewModel.isLocked, authViewModel.session != nil {
                    if authViewModel.biometricsEnabled {
                        // Face ID unlock screen
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
                        .transition(.opacity)
                        .onAppear {
                            Task { await authViewModel.unlockApp() }
                        }
                    } else {
                        // No biometrics → fallback to login
                        LoginView()
                            .environmentObject(authViewModel)
                            .transition(.opacity)
                    }
                }
            }
            // MARK: - Scene Phase Locking
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
