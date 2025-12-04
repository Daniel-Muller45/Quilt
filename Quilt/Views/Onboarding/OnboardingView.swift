import SwiftUI

struct OnboardingView: View {
    enum Step: Int, CaseIterable {
        case first = 0
        case second
        case third
    }
    
    @State private var currentStep: Step = .first
    
    let onFinished: () -> Void
    let onSignInTapped: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("Skip") {
                    onFinished()
                }
                .opacity(isLastStep ? 0 : 1)
                .disabled(isLastStep)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            Spacer()
            
            TabView(selection: $currentStep) {
                firstScreen
                    .tag(Step.first)
                secondScreen
                    .tag(Step.second)
                thirdScreen
                    .tag(Step.third)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Spacer()
            
            HStack {
                Button("Back") {
                    goBack()
                }
                .opacity(isFirstStep ? 0 : 1)
                .disabled(isFirstStep)
                
                Spacer()
                
                Button(isLastStep ? "Get Started" : "Next") {
                    if isLastStep {
                        onFinished()
                    } else {
                        goNext()
                    }
                }
            }
            .padding()
        }
    }
    
    private var firstScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image("onboarding_phone_mock")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Calorie tracking\nmade easy")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    goNext()
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(999)
                }
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                    Button(action: {
                        onSignInTapped()
                    }) {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 24)
            
            Spacer(minLength: 40)
        }
    }
    
    private var secondScreen: some View {
        VStack(spacing: 16) {
            Text("Screen 2")
                .font(.largeTitle.bold())
            Text("Explain how the app works or key features.")
        }
        .padding()
    }
    
    private var thirdScreen: some View {
        VStack(spacing: 16) {
            Text("Screen 3")
                .font(.largeTitle.bold())
            Text("Reassure, show security/trust, and prompt to start.")
        }
        .padding()
    }
    
    private var isFirstStep: Bool {
        currentStep == .first
    }
    
    private var isLastStep: Bool {
        currentStep == .third
    }
    
    private func goNext() {
        if let next = Step(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = next
            }
        }
    }
    
    private func goBack() {
        if let prev = Step(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = prev
            }
        }
    }
}
