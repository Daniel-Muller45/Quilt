import SwiftUI

@main
struct QuiltApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    OnboardingFlowView()
                        .preferredColorScheme(.dark)
                } else {
                    AuthRootView()
                }
            }
        }
    }
}
