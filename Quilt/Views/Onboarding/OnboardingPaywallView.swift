import SwiftUI

struct OnboardingPaywallView: View {
    var onSubscribed: () -> Void
    @State private var isLoading = false
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Unlock Full Access")
                .font(.title.bold())
            Text("Get daily portfolio syncs and personalized AI insights for $5/month.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button("Subscribe Now") {
                subscribe()
                hasCompletedOnboarding = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    func subscribe() {
        isLoading = true
        // Trigger your Stripe Checkout
        onSubscribed()
    }
}
