//
//  QuiltApp.swift
//  Quilt
//
//  Created by Daniel Muller on 10/23/25.
//

import SwiftUI

@main
struct QuiltApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}

