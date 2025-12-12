import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var currentPage = 0

    var body: some View {
        NavigationStack {
            VStack {
                if currentPage == 0 {
                    WelcomeView(onContinue: { currentPage = 1 })
                } else {
                    QuestionnaireView()
                }
            }
        }
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue, .blue.opacity(0.3))

            VStack(spacing: 12) {
                Text("Finance Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Track your everyday expenses quickly and easily")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 16) {
                FeatureRow(icon: "dollarsign.circle.fill", color: .green, text: "Quick interval-based input")
                FeatureRow(icon: "brain.head.profile", color: .purple, text: "Smart cost predictions")
                FeatureRow(icon: "chart.pie.fill", color: .orange, text: "Visual spending breakdown")
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ProfileManager())
}
