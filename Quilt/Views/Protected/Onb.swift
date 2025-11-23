import SwiftUI

// --- 1. Custom Colors and Data Structure ---

// Extend Color to easily define the dark theme accent colors
extension Color {
    // A dark charcoal color for the center of the spotlight (not pure black)
    static let darkCharcoal = Color(red: 0.05, green: 0.05, blue: 0.08)
    // The vibrant green accent color, similar to financial apps
    static let vibrantGreen = Color(red: 0.13, green: 0.73, blue: 0.33) // #22C55E
    // The deepest black for the edges
    static let deepBlack = Color.black
}

// Structure to hold the content for each onboarding page
struct OnboardingItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let subtitle: String
}

let onboardingData: [OnboardingItem] = [
    OnboardingItem(
        iconName: "chart.bar.fill",
        title: "Make better investments",
        subtitle: "Access commission-free trading and visualize your portfolio's growth in real time."
    ),
    OnboardingItem(
        iconName: "lock.shield.fill",
        title: "All in one place",
        subtitle: "Your data is protected with advanced encryption and two-factor authentication."
    ),
    OnboardingItem(
        iconName: "person.3.fill",
        title: "Join a community of serious investors",
        subtitle: "Over 10 million users trust us with their financial journey. Start yours today."
    )
]

// --- 2. Main Onboarding View ---

struct OnboardingView: View {
    // Tracks the current page index for navigation controls
    @State private var currentPage = 0
    // State to trigger the initial appearance animation
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            // 1. Spotlight Background Layer (Always full screen)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.darkCharcoal, // Center: Very dark gray
                    Color.deepBlack,    // Fades quickly to pure black
                    Color.deepBlack
                ]),
                center: .top,
                startRadius: 50,
                endRadius: 700
            )
            .ignoresSafeArea()
            
            // Optional: Subtle, slow-moving glow effect
            Circle()
                .fill(Color.vibrantGreen.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(y: -200) // Position the glow near the top center
                .opacity(contentVisible ? 1.0 : 0.0) // Animate it in
            
            // 2. TabView for Paging
            VStack {
                // Uses TabView style for automatic paging
                TabView(selection: $currentPage) {
                    ForEach(onboardingData.indices, id: \.self) { index in
                        OnboardingPageView(item: onboardingData[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Use dots from our custom view
                .ignoresSafeArea(.container, edges: .top) // Allows content to go up high
                
                // 3. Footer & Controls
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        // Custom Page Indicator Dots
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.vibrantGreen : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .animation(.easeOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Main Action Button (Glassmorphism/Jellyfish Style)
                    Button {
                        if currentPage < onboardingData.count - 1 {
                            // Go to next page
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            // Onboarding complete - Dismiss view/Navigate to app home
                            print("Onboarding Complete!")
                            // You would typically set a flag here (e.g., isFinished = true)
                        }
                    } label: {
                        Text(currentPage == onboardingData.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            // Set foreground to white for contrast on the dark background
                            .foregroundColor(.white)
                            // Apply the ultra-thin material for translucency
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            // Add a subtle white stroke for a defined "glass" edge
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            // Apply a wide, zero-offset shadow for a soft, encompassing glow
                            .shadow(color: Color.vibrantGreen.opacity(0.5), radius: 15, x: 0, y: 0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .offset(y: contentVisible ? 0 : 50) // Animate up from the bottom
                .opacity(contentVisible ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                contentVisible = true
            }
        }
    }
}

// --- 3. Single Onboarding Page View with Animations ---

struct OnboardingPageView: View {
    let item: OnboardingItem
    
    // State to control individual element animations
    @State private var iconScale: CGFloat = 0.5
    @State private var textOffset: CGFloat = 20
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            
            Image(systemName: item.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.vibrantGreen)
                .scaleEffect(iconScale) // Apply Scale Animation
                .opacity(opacity)       // Apply Fade Animation
            
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(item.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .offset(y: textOffset) // Apply Offset (Slide) Animation
            .opacity(opacity)
            
            Spacer()
        }
        .padding(.top, 100)
        .padding(.horizontal, 20)
        .onAppear {
            // Reset state for when the page reappears
            iconScale = 0.5
            textOffset = 20
            opacity = 0
            
            // Trigger the spring animation when the page appears
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.5)) {
                iconScale = 1.0
                textOffset = 0
                opacity = 1.0
            }
        }
    }
}

// --- 4. Preview (Optional: for testing in Xcode) ---
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
