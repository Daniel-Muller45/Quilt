import SwiftUI

struct OnboardingQuizView: View {
    struct QuizQuestion: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String?
        let options: [String]
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            title: "What’s your main goal with investing?",
            subtitle: nil,
            options: ["Grow long-term wealth", "Track performance more accurately", "Understand my portfolio better",
                      "Stay on top of market news", "Manage my risk"]
        ),
        QuizQuestion(
            title: "How experienced are you with investing?",
            subtitle: "Pick the one that fits best.",
            options: ["Beginner", "Intermediate", "Advanced"]
        ),
        QuizQuestion(
            title: "How often do you check or manage your investments?",
            subtitle: nil,
            options: ["Multiple times a day", "A few times a week", "A few times a month", "Rarely"]
        ),
        QuizQuestion(
            title: "What platforms do you invest through?",
            subtitle: nil,
            options: ["Robinhood", "Fidelity", "Schwab", "IRA / Roth IRA", "Crypto exchanges", "Other brokerages"]
        ),
        QuizQuestion(
            title: "What type of investor are you?",
            subtitle: nil,
            options: ["Long-term investor", "Swing trader", "Day trader", "Passive index investor"]
        ),
        QuizQuestion(
            title: "What's most import to you?",
            subtitle: nil,
            options: ["Performance vs last month", "Understanding portfolio allocation",
                      "Portfolio risk / volatility", "Market news for my holdings", "Dividends & income"]
        )
    ]
    
    @State private var currentIndex: Int = 0
    @State private var selections: [Int?]
    @State private var isBackwards = false
    
    @StateObject private var authViewModel = AuthViewModel()
    
    let onFinished: (_ selectedIndices: [Int]) -> Void
    
    init(onFinished: @escaping (_ selectedIndices: [Int]) -> Void) {
        self.onFinished = onFinished
        _selections = State(initialValue: Array(repeating: nil, count: 6))
    }
    
    // MARK: - Computed Properties
    
    private var isWelcomePage: Bool { currentIndex == 0 }
    
    // Connect Page is now: Questions Count + 1
    private var isConnectPage: Bool { currentIndex == questions.count + 1 }
    
    // Finish Page is now: Questions Count + 2
    private var isFinishPage: Bool { currentIndex == questions.count + 2 }
    
    private var isQuizPage: Bool { !isWelcomePage && !isConnectPage && !isFinishPage }
    
    private var questionIndex: Int { currentIndex - 1 }
    
    private var currentQuestion: QuizQuestion {
        questions[questionIndex]
    }
    
    private var progressValue: Double {
        if isWelcomePage { return 0.0 }
        // If we are on Connect or Finish, show full bar
        if isConnectPage || isFinishPage { return 1.0 }
        return Double(currentIndex) / Double(questions.count)
    }
    
    private var mainButtonTitle: String {
        if isWelcomePage { return "Get Started" }
        if isFinishPage { return "Start Tracking" }
        // On Connect page, button acts as a "Skip" or "Next"
        if isConnectPage { return "Next" }
        return currentIndex == questions.count ? "Next" : "Next"
    }
    
    private var canContinue: Bool {
        // Allow continue on non-quiz pages
        if isWelcomePage || isConnectPage || isFinishPage { return true }
        // For quiz, check selection
        return selections[questionIndex] != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Top Navigation
                if (!isConnectPage && !isFinishPage) {
                    HStack {
                        if currentIndex > 0 {
                            Button(action: handleBack) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .contentShape(Rectangle())
                            }
                            .transition(.opacity)
                        } else {
                            Color.clear.frame(width: 40, height: 40)
                        }
                        
                        if isQuizPage {
                            ProgressView(value: progressValue)
                                .progressViewStyle(.linear)
                                .tint(Color.white)
                                .transition(.opacity)
                        } else {
                            Spacer().frame(height: 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Main Content
                VStack {
                    if isWelcomePage {
                        GetStartedView()
                            .transition(activeTransition)
                    } else if isConnectPage {
                        // Inserted Connect View
                        connectView
                            .transition(activeTransition)
                    } else if isFinishPage {
                        finishView
                            .transition(activeTransition)
                    } else {
                        quizContent
                            .transition(activeTransition)
                            .id(currentIndex)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Bottom Button
                if !isConnectPage {
                    Button(action: handleContinue) {
                        Text(mainButtonTitle)
                            .font(.headline)
                            .foregroundColor(canContinue ? Color.black : Color.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canContinue ? Color.white : Color.gray.opacity(0.4))
                            .cornerRadius(999)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .disabled(!canContinue)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    )
                }
                
                // Login Link (Welcome Page Only)
                if isWelcomePage {
                    NavigationLink(
                        destination: LoginView()
                            .environmentObject(authViewModel)
                            .preferredColorScheme(.dark)
                    ) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.primary)
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 20)
                }
            }
            .animation(.spring(), value: currentIndex)
        }
    }
    
    // MARK: - Subviews
    
    private var welcomeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text("Welcome")
                .font(.largeTitle.bold())
            
            Text("Let's personalize your experience to help you track what matters most.")
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var finishView: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.green)
                .padding(.bottom, 20)
            
            Text("All Set!")
                .font(.largeTitle.bold())
            
            Text("Your dashboard is ready.")
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    private var connectView: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
//            
            Text("Get Started by Connecting a Brokerage")
                .font(.title2.bold()) // Adjusted font slightly
                .multilineTextAlignment(.center)
            
            OnboardingConnectView(token: "")
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
    
    private var quizContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(currentQuestion.title)
                    .font(.title2.bold())
                
                if let subtitle = currentQuestion.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    optionRow(title: option, isSelected: selections[questionIndex] == index)
                        .onTapGesture {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            selections[questionIndex] = index
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
    
    private func optionRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(isSelected ? .black : .white)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.white : Color(.systemGray6))
        )
    }
    
    private var activeTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: isBackwards ? .leading : .trailing),
            removal: .move(edge: isBackwards ? .trailing : .leading)
        )
    }
    
    // MARK: - Handlers
    
    private func handleContinue() {
        guard canContinue else { return }
        
        if isFinishPage {
            let indices = selections.compactMap { $0 }
            onFinished(indices)
        } else {
            // Proceed to next step
            isBackwards = false
            withAnimation {
                currentIndex += 1
            }
        }
    }
    
    private func handleBack() {
        guard currentIndex > 0 else { return }
        isBackwards = true
        withAnimation {
            currentIndex -= 1
        }
    }
}
