import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = true
    @Published var biometricsEnabled = false
    @Published var isLocked = true

    private let service = SupabaseService.shared
    private let keychain = KeychainService.shared

    init() {
        Task { await loadSession() }
    }

    func loadSession() async {
        self.session = try? await service.getSession()
        self.isLoading = false
        self.biometricsEnabled = BiometricService.shared.isBiometricsAvailable() &&
                                 keychain.read(service: "Quilt", account: "email") != nil
    }

    func signIn(email: String, password: String, remember: Bool = true) async throws {
        let session = try await service.signIn(email: email, password: password)
        self.session = session
        self.isLocked = false
        if remember {
            keychain.save(email, service: "Quilt", account: "email")
            keychain.save(password, service: "Quilt", account: "password")
        }

        biometricsEnabled = BiometricService.shared.isBiometricsAvailable() &&
                            keychain.read(service: "Quilt", account: "email") != nil
    }

    
    func signUp(email: String, password: String) async throws {
        let response = try await service.signUp(email: email, password: password)
        self.session = response.session
    }


    func signOut() async {
        try? await service.signOut()
        session = nil
    }

    func biometricLogin() async {
        guard BiometricService.shared.isBiometricsAvailable() else {
            return
        }

        do {
            let success = try await BiometricService.shared.authenticate()

            if success {
                let email = keychain.read(service: "Quilt", account: "email")
                let password = keychain.read(service: "Quilt", account: "password")

                if let email, let password {
                    try await signIn(email: email, password: password, remember: true)
                    print("Signed in with stored credentials")

                    biometricsEnabled = BiometricService.shared.isBiometricsAvailable() &&
                                        keychain.read(service: "Quilt", account: "email") != nil
                } else {
                    print("No stored credentials found in Keychain")
                }
            }
        } catch {
            print("Biometric login failed:", error.localizedDescription)
        }
    }

    func lockApp() {
        isLocked = true
    }
    
    func unlockApp() async {
        guard BiometricService.shared.isBiometricsAvailable() else { return }
        do {
            let success = try await BiometricService.shared.authenticate(reason: "Unlock Quilt")
            if success { isLocked = false }
        } catch {
            print("Face ID failed: ", error.localizedDescription)
            isLocked = true
        }
    }

}
