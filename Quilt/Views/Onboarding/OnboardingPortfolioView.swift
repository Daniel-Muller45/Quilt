import SwiftUI

struct OnboardingPortfolioView: View {
    var holdings: [Holding]
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Your Portfolio Snapshot")
                .font(.title2.bold())

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                VStack {
                    Text("🔒 AI Insights Locked")
                        .font(.headline)
                    Text("Sign up to save and unlock insights.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .frame(height: 140)
            .padding()

            Button("Continue") { onContinue() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }
}
