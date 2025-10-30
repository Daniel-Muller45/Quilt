import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack {
            switch viewModel.currentStep {
            case .welcome:
                OnboardingWelcomeView {
                    viewModel.init_user()
                }
            case .connect:
                OnboardingConnectBrokerageView(viewModel: viewModel) {
                    viewModel.next()
                }
            case .preview:
                OnboardingPortfolioView(holdings: viewModel.holdings) {
                    viewModel.next()
                }
            case .signup:
                OnboardingSignupView {
                    viewModel.next()
                }
            case .paywall:
                OnboardingPaywallView {
                    viewModel.next()
                }
            case .done:
                MainTabView()
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
        .transition(.slide)
    }
}
