import Foundation
import SwiftUI

class FinanceManager: ObservableObject {
    @Published var transactions: [Transaction] = []

    private let transactionsKey = "savedTransactions"

    init() {
        loadTransactions()
    }

    // MARK: - Transaction Management

    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        saveTransactions()
    }

    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }

    func deleteTransactions(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }

    // MARK: - Statistics

    var todayTotal: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return transactions
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }

    var weekTotal: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return transactions
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.amount }
    }

    var monthTotal: Double {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return transactions
            .filter { $0.date >= monthAgo }
            .reduce(0) { $0 + $1.amount }
    }

    func totalForCategory(_ category: ExpenseCategory) -> Double {
        transactions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    var categoryBreakdown: [(category: ExpenseCategory, total: Double)] {
        var breakdown: [ExpenseCategory: Double] = [:]
        for transaction in transactions {
            breakdown[transaction.category, default: 0] += transaction.amount
        }
        return breakdown.map { ($0.key, $0.value) }
            .sorted { $0.total > $1.total }
    }

    var recentTransactions: [Transaction] {
        Array(transactions.prefix(10))
    }

    // MARK: - Persistence

    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }

    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
}
