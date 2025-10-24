//
//  PortfolioView.swift
//  Quilt
//
//  Created by Daniel Muller on 10/23/25.
//

import SwiftUI

struct PortfolioView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Portfolio ")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .navigationTitle("Quilt")
        }
    }
}
