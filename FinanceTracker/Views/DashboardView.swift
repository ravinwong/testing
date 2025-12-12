import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary cards
                    summaryCards

                    // Category breakdown
                    if !financeManager.categoryBreakdown.isEmpty {
                        categoryBreakdown
                    }

                    // Recent transactions
                    if !financeManager.recentTransactions.isEmpty {
                        recentTransactions
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Today",
                    amount: financeManager.todayTotal,
                    icon: "sun.max.fill",
                    color: .orange
                )

                SummaryCard(
                    title: "This Week",
                    amount: financeManager.weekTotal,
                    icon: "calendar",
                    color: .blue
                )
            }

            SummaryCard(
                title: "This Month",
                amount: financeManager.monthTotal,
                icon: "calendar.circle.fill",
                color: .purple,
                isLarge: true
            )
        }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(financeManager.categoryBreakdown.prefix(5), id: \.category) { item in
                    CategoryRow(
                        category: item.category,
                        amount: item.total,
                        percentage: item.total / financeManager.monthTotal
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: HistoryView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 0) {
                ForEach(financeManager.recentTransactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)

                    if transaction.id != financeManager.recentTransactions.prefix(5).last?.id {
                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No transactions yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Start tracking your expenses by tapping the Add tab")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    var isLarge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(isLarge ? .title2 : .title3)
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(formatAmount(amount))
                .font(isLarge ? .largeTitle : .title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func formatAmount(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}

struct CategoryRow: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(categoryColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(categoryColor)
                            .frame(width: geometry.size.width * min(percentage, 1), height: 6)
                    }
                }
                .frame(height: 6)
            }

            Text(formatAmount(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
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
        String(format: "$%.2f", value)
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(categoryColor)
                .frame(width: 36, height: 36)
                .background(categoryColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatAmount(transaction.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }

    private var categoryColor: Color {
        switch transaction.category {
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
        String(format: "$%.2f", value)
    }
}

#Preview {
    DashboardView()
        .environmentObject(FinanceManager())
        .environmentObject(ProfileManager())
}
