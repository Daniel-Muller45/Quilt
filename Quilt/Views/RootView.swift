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
    
    var body: some View {
        ZStack {
            if authViewModel.isLoading {
                LoadingView()
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
