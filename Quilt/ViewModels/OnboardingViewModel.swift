import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome, connect, preview, signup, paywall, done
    }

    @Published var currentStep: Step = .welcome
    @Published var onboardingUserId: String
    @Published var brokerageLinked = false
    @Published var holdings: [Holding] = []
    
    @StateObject private var brokerageViewModel = BrokerageViewModel()
    
    init() {
        if let savedUID = UserDefaults.standard.string(forKey: "onboarding_user_id") {
            onboardingUserId = savedUID
        } else {
            onboardingUserId = UUID().uuidString
            UserDefaults.standard.set(onboardingUserId, forKey: "onboarding_user_id")
        }
    }

    func next() {
        if let nextStep = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    func generateUID() {
        let newUID = UUID().uuidString
        onboardingUserId = newUID
        UserDefaults.standard.set(newUID, forKey: "onboarding_user_id")
    }

    func init_user() {
        generateUID()
        next()
        brokerageViewModel.registerPublicUser(uid: onboardingUserId)
    }
    func reset() {
        currentStep = .welcome
        generateUID()
        brokerageLinked = false
        holdings = []
    }
}
