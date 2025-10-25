import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await signIn() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                if authViewModel.biometricsEnabled {
                    Button {
                        Task { await authViewModel.biometricLogin() }
                    } label: {
                        Label("Sign in with Face ID", systemImage: "faceid")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                }

                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                NavigationLink("Don't have an account? Sign Up") {
                    SignupView()
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }

    func signIn() async {
        isLoading = true
        message = ""
        do {
            try await authViewModel.signIn(email: email, password: password)
            message = "Signed in successfully!"
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
