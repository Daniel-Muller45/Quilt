import SwiftUI

struct GetStartedView: View {
    
    @State private var showPhone = false
    @State private var displayedText = ""
    private let fullText = "Your investing copilot"
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image("onboarding_phone_mock")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .offset(y: showPhone ? 0 : -300)
                .opacity(showPhone ? 1 : 0)
            
            Text(displayedText)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
//                .padding(.bottom, 2)
                .frame(minHeight: 80, alignment: .top)
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateScreen()
        }
    }
    
    func animateScreen() {
        guard displayedText.isEmpty else { return }
        
        withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) {
            showPhone = true
        }
        
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            for (index, character) in fullText.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(index))) {
                    displayedText.append(character)
                    haptic.impactOccurred()
                }
            }
        }
    }
}
