import SwiftUI

struct ProfileAnalysisView: View {
    @EnvironmentObject var profileManager: ProfileManager
    let profile: UserProfile
    @State private var animateCards = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                        .scaleEffect(animateCards ? 1 : 0.5)
                        .opacity(animateCards ? 1 : 0)

                    Text("Profile Complete!")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Based on your answers, we've estimated costs for common expenses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Your answers summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Answers")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        AnswerRow(icon: "cup.and.saucer.fill", label: "Coffee", value: profile.coffeeCost)
                        AnswerRow(icon: "fork.knife", label: "Lunch", value: profile.lunchCost)
                        AnswerRow(icon: "fork.knife.circle.fill", label: "Dinner", value: profile.dinnerCost)
                        AnswerRow(icon: "cart.fill", label: "Weekly Groceries", value: profile.groceriesWeekly)
                        AnswerRow(icon: "car.fill", label: "Monthly Transport", value: profile.transportationMonthly)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 20)

                // Estimated costs
                VStack(alignment: .leading, spacing: 12) {
                    Text("Auto-filled Estimates")
                        .font(.headline)
                        .padding(.horizontal)

                    Text("These will be suggested when you add expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(sortedEstimates, id: \.0) { category, estimate in
                            EstimateCard(category: category, estimate: estimate)
                        }
                    }
                    .padding(.horizontal)
                }
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 30)

                // Continue button
                Button(action: {
                    profileManager.updateProfile(profile)
                    profileManager.completeOnboarding()
                }) {
                    Text("Start Tracking")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 40)
                .opacity(animateCards ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
        }
    }

    private var sortedEstimates: [(ExpenseCategory, Double)] {
        profile.estimatedCosts
            .filter { ![$0.key].contains(where: { [.coffee, .lunch, .dinner].contains($0) }) }
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
}

struct AnswerRow: View {
    let icon: String
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(label)
                .foregroundColor(.primary)

            Spacer()

            Text(formatAmount(value))
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }

    private func formatAmount(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "$%.0f", value)
        } else if value == value.rounded() {
            return String(format: "$%.0f", value)
        } else {
            return String(format: "$%.2f", value)
        }
    }
}

struct EstimateCard: View {
    let category: ExpenseCategory
    let estimate: Double

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(categoryColor)

            Text(category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(formatAmount(estimate))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var categoryColor: Color {
        switch category {
        case .coffee: return .brown
        case .lunch, .fastFood: return .orange
        case .dinner: return .red
        case .groceries: return .green
        case .transportation, .gas, .parking: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .utilities: return .yellow
        case .healthcare: return .teal
        case .subscriptions: return .indigo
        case .snacks: return .mint
        case .drinks: return .purple
        case .other: return .gray
        }
    }

    private func formatAmount(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "$%.0f", value)
        } else if value == value.rounded() {
            return String(format: "$%.0f", value)
        } else {
            return String(format: "$%.2f", value)
        }
    }
}

#Preview {
    ProfileAnalysisView(profile: UserProfile(
        coffeeCost: 5,
        lunchCost: 12,
        dinnerCost: 25,
        groceriesWeekly: 100,
        transportationMonthly: 150
    ))
    .environmentObject(ProfileManager())
}
