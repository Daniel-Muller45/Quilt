//
//  RootView.swift
//  Quilt
//
//  Created by Daniel Muller on 10/29/25.
//
import SwiftUI

struct AuthRootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var quizDone = false
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if authViewModel.isLoading {
                LoadingView()
                    .preferredColorScheme(.dark)
            } else if !hasCompletedOnboarding {
                OnboardingQuizView { answers in
//                    quizAnswers = answers     // store if needed later
                    quizDone = true           // trigger navigation
                }
                .navigationDestination(isPresented: $quizDone) {
                    OnboardingConnectView(token: "")
                }
                .preferredColorScheme(.dark)
            } else if authViewModel.session == nil {
                LoginView()
                    .environmentObject(authViewModel)
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
