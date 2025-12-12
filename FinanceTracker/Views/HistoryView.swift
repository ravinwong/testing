import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var searchText = ""
    @State private var selectedFilter: ExpenseCategory?
    @State private var showingFilters = false

    var filteredTransactions: [Transaction] {
        var result = financeManager.transactions

        if !searchText.isEmpty {
            result = result.filter {
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let filter = selectedFilter {
            result = result.filter { $0.category == filter }
        }

        return result
    }

    var groupedTransactions: [(key: String, transactions: [Transaction])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> String in
            formatter.string(from: transaction.date)
        }

        return grouped.map { (key: $0.key, transactions: $0.value) }
            .sorted { $0.transactions.first?.date ?? Date() > $1.transactions.first?.date ?? Date() }
    }

    var body: some View {
        NavigationStack {
            Group {
                if financeManager.transactions.isEmpty {
                    emptyState
                } else {
                    transactionList
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { selectedFilter = nil }) {
                            Label("All Categories", systemImage: selectedFilter == nil ? "checkmark" : "")
                        }

                        Divider()

                        ForEach(ExpenseCategory.allCases) { category in
                            Button(action: { selectedFilter = category }) {
                                Label(category.rawValue, systemImage: selectedFilter == category ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: selectedFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
        }
    }

    private var transactionList: some View {
        List {
            ForEach(groupedTransactions, id: \.key) { group in
                Section(header: Text(group.key)) {
                    ForEach(group.transactions) { transaction in
                        TransactionDetailRow(transaction: transaction)
                    }
                    .onDelete { offsets in
                        deleteTransactions(from: group.transactions, at: offsets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Transaction History")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your expenses will appear here once you start tracking")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func deleteTransactions(from transactions: [Transaction], at offsets: IndexSet) {
        for index in offsets {
            financeManager.deleteTransaction(transactions[index])
        }
    }
}

struct TransactionDetailRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(transaction.date, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatAmount(transaction.amount))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
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
    HistoryView()
        .environmentObject(FinanceManager())
}
