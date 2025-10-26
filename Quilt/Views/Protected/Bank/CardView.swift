//
//  CardView.swift
//  Example
//
//  Created by Danil Kristalev on 30.12.2021.
//  Modified by Daniel Muller on 2025-10-25.
//

import SwiftUI

struct CardView: View {
    var progress: CGFloat

    private var isCollapsed: Bool { progress > 0.7 }

    private var balance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        let number = NSNumber(value: 56112.65)
        return "$" + (formatter.string(from: number) ?? "0.00")
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<5) { index in
                    singleCard(index: index)
                        .frame(width: 320)
                        .padding(.vertical, 20)
                        .animation(.easeInOut(duration: 0.25), value: progress)
                }
            }
            .padding(.horizontal)
        }
    }

    private func singleCard(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color("PrimaryColor"),
                        Color("PrimaryColor").opacity(0.85)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: isCollapsed ? 80 : 230)
                .shadow(radius: 5)
                .animation(.easeInOut(duration: 0.25), value: isCollapsed)

            VStack(alignment: .leading, spacing: 16) {
                // Always visible section — balance
                HStack {
                    VStack(alignment: .leading) {
                        Text("BALANCE")
                            .font(.caption)
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.8))
                        Text(balance)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }

                // Expanded card details
                if !isCollapsed {
                    VStack(spacing: 16) {
                        HStack {
                            Text("**** **** **** 0777")
                                .foregroundColor(.white)
                            Spacer()
                            Image("Visa")
                                .resizable()
                                .frame(width: 60, height: 18)
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text("CARD HOLDER")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("TOM HOLLAND")
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("EXPIRES")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("11/24")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    // Simulate collapsing animation
    VStack {
        CardView(progress: 0.0)
        CardView(progress: 1.0)
    }
    .background(Color.black.opacity(0.1))
}
