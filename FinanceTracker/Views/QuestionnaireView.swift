import SwiftUI

struct QuestionnaireView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var currentQuestionIndex = 0
    @State private var answers: [Double] = Array(repeating: 0, count: QuestionnaireQuestion.allQuestions.count)
    @State private var showingResults = false

    private let questions = QuestionnaireQuestion.allQuestions

    init() {
        _answers = State(initialValue: questions.map { $0.defaultValue })
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                .tint(.blue)
                .padding(.horizontal)
                .padding(.top)

            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)

            if showingResults {
                ProfileAnalysisView(profile: buildProfile())
            } else {
                questionCard
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var questionCard: some View {
        VStack(spacing: 24) {
            Spacer()

            // Question icon
            questionIcon
                .font(.system(size: 60))
                .foregroundStyle(.blue, .blue.opacity(0.3))
                .padding(.bottom, 10)

            // Question text
            VStack(spacing: 8) {
                Text(questions[currentQuestionIndex].question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(questions[currentQuestionIndex].hint)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Amount display
            Text(formatAmount(answers[currentQuestionIndex]))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            // Slider
            VStack(spacing: 8) {
                Slider(
                    value: $answers[currentQuestionIndex],
                    in: questions[currentQuestionIndex].minValue...questions[currentQuestionIndex].maxValue,
                    step: sliderStep
                )
                .tint(.blue)
                .padding(.horizontal, 30)

                HStack {
                    Text(formatAmount(questions[currentQuestionIndex].minValue))
                    Spacer()
                    Text(formatAmount(questions[currentQuestionIndex].maxValue))
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
            }

            // Quick select buttons
            quickSelectButtons

            Spacer()

            // Navigation buttons
            navigationButtons
        }
        .padding()
    }

    private var questionIcon: some View {
        Group {
            switch questions[currentQuestionIndex].category {
            case .coffee:
                Image(systemName: "cup.and.saucer.fill")
            case .lunch:
                Image(systemName: "fork.knife")
            case .dinner:
                Image(systemName: "fork.knife.circle.fill")
            case .groceries:
                Image(systemName: "cart.fill")
            case .transportation:
                Image(systemName: "car.fill")
            }
        }
    }

    private var sliderStep: Double {
        let range = questions[currentQuestionIndex].maxValue - questions[currentQuestionIndex].minValue
        if range <= 20 {
            return 1
        } else if range <= 100 {
            return 5
        } else {
            return 10
        }
    }

    private var quickSelectButtons: some View {
        let q = questions[currentQuestionIndex]
        let range = q.maxValue - q.minValue
        let step = range / 4
        let presets = [q.minValue, q.minValue + step, q.minValue + step * 2, q.minValue + step * 3, q.maxValue]

        return HStack(spacing: 8) {
            ForEach(presets, id: \.self) { value in
                Button(action: { answers[currentQuestionIndex] = value }) {
                    Text(formatCompact(value))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(answers[currentQuestionIndex] == value ? Color.blue : Color(.systemGray5))
                        .foregroundColor(answers[currentQuestionIndex] == value ? .white : .primary)
                        .cornerRadius(8)
                }
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentQuestionIndex > 0 {
                Button(action: { currentQuestionIndex -= 1 }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(14)
                }
            }

            Button(action: {
                if currentQuestionIndex < questions.count - 1 {
                    withAnimation {
                        currentQuestionIndex += 1
                    }
                } else {
                    withAnimation {
                        showingResults = true
                    }
                }
            }) {
                HStack {
                    Text(currentQuestionIndex < questions.count - 1 ? "Next" : "See Results")
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(14)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private func buildProfile() -> UserProfile {
        UserProfile(
            coffeeCost: answers[0],
            lunchCost: answers[1],
            dinnerCost: answers[2],
            groceriesWeekly: answers[3],
            transportationMonthly: answers[4]
        )
    }

    private func formatAmount(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "$%.0f", value)
        } else {
            return String(format: "$%.2f", value)
        }
    }

    private func formatCompact(_ value: Double) -> String {
        if value >= 100 {
            return "$\(Int(value))"
        } else if value == value.rounded() {
            return "$\(Int(value))"
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

#Preview {
    NavigationStack {
        QuestionnaireView()
            .environmentObject(ProfileManager())
    }
}
