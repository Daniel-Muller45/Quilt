import LocalAuthentication
import Foundation

final class BiometricService {
    static let shared = BiometricService()
    private init() {}

    func authenticate(reason: String = "Log in with Face ID") async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw error ?? NSError(domain: "BiometricAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Biometrics not available"])
        }

        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }

    func isBiometricsAvailable() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
