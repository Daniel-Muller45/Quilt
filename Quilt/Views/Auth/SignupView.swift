import SwiftUI
import Supabase

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)

            Button {
                Task { await signUp() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)

            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Already have an account? Sign In") {
                dismiss()
            }
            .padding(.top)
        }
        .padding()
    }

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            message = "Passwords do not match."
            return
        }

        isLoading = true
        message = ""

        do {
            let response = try await SupabaseService.shared.client.auth.signUp(
                email: email,
                password: password
            )

            if response.user != nil {
                message = "Account created! Please check your email to verify."
                // Optionally: auto-dismiss or navigate to login after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            } else {
                message = "Signup successful — check your email to verify."
            }
        } catch {
            message = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
