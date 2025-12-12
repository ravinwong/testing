import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingResetAlert = false
    @State private var showingClearDataAlert = false
    @State private var showingRetakeQuestionnaire = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    NavigationLink(destination: ProfileDetailView()) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your Profile")
                                    .font(.headline)
                                Text("View and edit cost estimates")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Button(action: { showingRetakeQuestionnaire = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.orange)
                            Text("Retake Questionnaire")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Profile")
                }

                // Statistics Section
                Section {
                    StatRow(label: "Total Transactions", value: "\(financeManager.transactions.count)")
                    StatRow(label: "Total Spent", value: formatAmount(totalSpent))
                    StatRow(label: "Average per Transaction", value: formatAmount(averageTransaction))
                    StatRow(label: "Most Common Category", value: mostCommonCategory?.rawValue ?? "N/A")
                } header: {
                    Text("Statistics")
                }

                // Data Section
                Section {
                    Button(action: { showingClearDataAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Transactions")
                                .foregroundColor(.red)
                        }
                    }

                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("Reset Everything")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Clearing data cannot be undone")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Transactions?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllTransactions()
                }
            } message: {
                Text("This will permanently delete all your transaction history.")
            }
            .alert("Reset Everything?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetEverything()
                }
            } message: {
                Text("This will delete all data and return to the questionnaire.")
            }
            .sheet(isPresented: $showingRetakeQuestionnaire) {
                NavigationStack {
                    QuestionnaireView()
                        .environmentObject(profileManager)
                }
            }
        }
    }

    private var totalSpent: Double {
        financeManager.transactions.reduce(0) { $0 + $1.amount }
    }

    private var averageTransaction: Double {
        guard !financeManager.transactions.isEmpty else { return 0 }
        return totalSpent / Double(financeManager.transactions.count)
    }

    private var mostCommonCategory: ExpenseCategory? {
        let counts = Dictionary(grouping: financeManager.transactions) { $0.category }
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private func formatAmount(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    private func clearAllTransactions() {
        for transaction in financeManager.transactions {
            financeManager.deleteTransaction(transaction)
        }
    }

    private func resetEverything() {
        clearAllTransactions()
        profileManager.resetOnboarding()
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
}

struct ProfileDetailView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        List {
            Section {
                ProfileRow(label: "Coffee", value: profileManager.profile.coffeeCost)
                ProfileRow(label: "Lunch", value: profileManager.profile.lunchCost)
                ProfileRow(label: "Dinner", value: profileManager.profile.dinnerCost)
                ProfileRow(label: "Weekly Groceries", value: profileManager.profile.groceriesWeekly)
                ProfileRow(label: "Monthly Transport", value: profileManager.profile.transportationMonthly)
            } header: {
                Text("Your Answers")
            }

            Section {
                ForEach(ExpenseCategory.allCases) { category in
                    ProfileRow(
                        label: category.rawValue,
                        value: profileManager.estimatedCost(for: category),
                        icon: category.icon
                    )
                }
            } header: {
                Text("Estimated Costs")
            } footer: {
                Text("These estimates are used for quick-add suggestions")
            }
        }
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileRow: View {
    let label: String
    let value: Double
    var icon: String? = nil

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
            }

            Text(label)

            Spacer()

            Text(formatAmount(value))
                .foregroundColor(.secondary)
                .fontWeight(.medium)
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
    SettingsView()
        .environmentObject(ProfileManager())
        .environmentObject(FinanceManager())
}
