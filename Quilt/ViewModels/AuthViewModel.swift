import Supabase
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let client = SupabaseService.shared.client

    init() {
        Task {
            await loadSession()
        }
    }

    func loadSession() async {
        do {
            let current = try await client.auth.session
            self.session = current
        } catch {
            self.session = nil
        }
        isLoading = false
    }
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)

        do {
            let current = try await client.auth.session
            self.session = current
        } catch {
            self.session = nil
            throw error
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            print("Sign out error:", error)
        }
        self.session = nil
    }
}
