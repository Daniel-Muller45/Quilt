//
//  ContentView.swift
//  Quilt
//
//  Created by Daniel Muller on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isSignedIn {
                PortfolioView()
            } else {
                LoginView()
            }
        }
    }
}
