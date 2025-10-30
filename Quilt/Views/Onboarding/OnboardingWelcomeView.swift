import SwiftUI

struct OnboardingWelcomeView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Welcome to Quilt")
                .font(.largeTitle.bold())
            Text("Track all your investments in one place.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button("Get Started") { onNext() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }
}
