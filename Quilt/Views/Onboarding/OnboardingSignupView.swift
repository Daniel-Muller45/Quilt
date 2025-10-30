import SwiftUI

struct OnboardingSignupView: View {
    var onNext: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Account")
                .font(.title2.bold())
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Sign Up") {  }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            if let error = error {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}
