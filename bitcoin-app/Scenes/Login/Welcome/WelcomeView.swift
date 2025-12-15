import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct OnboardingFlowTemplate: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    
    let onboardingPages = [
        OnboardingPage(
            image: "figure.mind.and.body",
            title: "Welcome to Health+",
            description: "Your journey to a healthier lifestyle starts here. Track your progress and achieve your goals."
        ),
        OnboardingPage(
            image: "chart.bar.fill",
            title: "Track Your Progress",
            description: "Monitor your daily activities, set personal goals, and watch your achievements grow over time."
        ),
        OnboardingPage(
            image: "person.2.fill",
            title: "Join the Community",
            description: "Connect with like-minded people, share your journey, and get inspired by others' success stories."
        )
    ]
    
    var body: some View {
        Group {
            if isOnboardingComplete {
                HomeView()
            } else {
                onboardingView
            }
        }
    }
    
    private var onboardingView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        isOnboardingComplete = true
                    }) {
                        Text("Skip")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(onboardingPages.indices, id: \.self) { index in
                        VStack(spacing: 32) {
                            Image(systemName: onboardingPages[index].image)
                                .font(.system(size: 100))
                                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding()
                                .symbolEffect(.pulse, options: .nonRepeating)
                            
                            Text(onboardingPages[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(onboardingPages[index].description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Progress and Continue button
                VStack(spacing: 24) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding()
                    
                    // Continue button
                    Button(action: {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            isOnboardingComplete = true
                        }
                    }) {
                        Text(currentPage < onboardingPages.count - 1 ? "Continue" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
