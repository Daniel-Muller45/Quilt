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

            if authViewModel.isLocked, authViewModel.session != nil {
                if authViewModel.biometricsEnabled {
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
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
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
