import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @EnvironmentObject var profileManager: ProfileManager

    @State private var amount: Double = 0
    @State private var selectedCategory: ExpenseCategory = .coffee
    @State private var note: String = ""
    @State private var showingSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick category selection with auto-fill
                    quickCategoryGrid

                    // Interval-based input
                    IntervalInputView(amount: $amount)

                    // Optional note
                    noteSection

                    // Add button
                    addButton

                    // Quick add buttons for common items
                    quickAddSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Expense")
            .overlay {
                if showingSuccess {
                    successOverlay
                }
            }
        }
    }

    private var quickCategoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(ExpenseCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        estimatedCost: profileManager.roundedEstimate(for: category),
                        action: {
                            selectedCategory = category
                            // Auto-fill with estimated cost
                            if amount == 0 {
                                amount = profileManager.roundedEstimate(for: category)
                            }
                        }
                    )
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (optional)")
                .font(.headline)

            TextField("Add a note...", text: $note)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }

    private var addButton: some View {
        Button(action: addTransaction) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add \(formatAmount(amount))")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(amount > 0 ? Color.blue : Color.gray)
            .cornerRadius(14)
        }
        .disabled(amount <= 0)
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)

            Text("Tap to instantly add with estimated cost")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                QuickAddButton(
                    category: .coffee,
                    amount: profileManager.roundedEstimate(for: .coffee),
                    action: { quickAdd(category: .coffee) }
                )

                QuickAddButton(
                    category: .lunch,
                    amount: profileManager.roundedEstimate(for: .lunch),
                    action: { quickAdd(category: .lunch) }
                )

                QuickAddButton(
                    category: .transportation,
                    amount: profileManager.roundedEstimate(for: .transportation),
                    action: { quickAdd(category: .transportation) }
                )

                QuickAddButton(
                    category: .snacks,
                    amount: profileManager.roundedEstimate(for: .snacks),
                    action: { quickAdd(category: .snacks) }
                )
            }
        }
    }

    private var successOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Added!")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .transition(.scale.combined(with: .opacity))
    }

    private func addTransaction() {
        let transaction = Transaction(
            amount: amount,
            category: selectedCategory,
            note: note
        )
        financeManager.addTransaction(transaction)

        // Show success feedback
        withAnimation(.spring()) {
            showingSuccess = true
        }

        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showingSuccess = false
                amount = 0
                note = ""
            }
        }
    }

    private func quickAdd(category: ExpenseCategory) {
        let transaction = Transaction(
            amount: profileManager.roundedEstimate(for: category),
            category: category
        )
        financeManager.addTransaction(transaction)

        withAnimation(.spring()) {
            showingSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showingSuccess = false
            }
        }
    }

    private func formatAmount(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "$%.0f", value)
        } else {
            return String(format: "$%.2f", value)
        }
    }
}

struct CategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let estimatedCost: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.rawValue)
                    .font(.system(size: 9))
                    .lineLimit(1)

                if estimatedCost > 0 {
                    Text("$\(Int(estimatedCost))")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(isSelected ? .white : categoryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? categoryColor : categoryColor.opacity(0.15))
            .cornerRadius(10)
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
}

struct QuickAddButton: View {
    let category: ExpenseCategory
    let amount: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(categoryColor)
                    .frame(width: 40, height: 40)
                    .background(categoryColor.opacity(0.15))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(formatAmount(amount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
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
        String(format: "$%.0f", value)
    }
}

#Preview {
    QuickAddView()
        .environmentObject(FinanceManager())
        .environmentObject(ProfileManager())
}
