import SwiftUI

struct IntervalInputView: View {
    @Binding var amount: Double
    let intervals: [Double] = [1, 5, 10, 20, 50, 100]

    var body: some View {
        VStack(spacing: 16) {
            // Amount display
            Text(formatAmount(amount))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.systemGray6))
                .cornerRadius(16)

            // Interval buttons
            HStack(spacing: 8) {
                ForEach(intervals, id: \.self) { interval in
                    IntervalButton(
                        interval: interval,
                        action: { amount += interval },
                        isAdd: true
                    )
                }
            }

            HStack(spacing: 8) {
                ForEach(intervals, id: \.self) { interval in
                    IntervalButton(
                        interval: interval,
                        action: {
                            amount = max(0, amount - interval)
                        },
                        isAdd: false
                    )
                }
            }

            // Quick actions
            HStack(spacing: 12) {
                Button(action: { amount = 0 }) {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(10)
                }

                Button(action: { amount = (amount * 10).rounded() / 10 }) {
                    Text("Round")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    private func formatAmount(_ amount: Double) -> String {
        if amount == amount.rounded() {
            return String(format: "$%.0f", amount)
        } else {
            return String(format: "$%.2f", amount)
        }
    }
}

struct IntervalButton: View {
    let interval: Double
    let action: () -> Void
    let isAdd: Bool

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(isAdd ? "+" : "-")
                    .font(.system(size: 14, weight: .bold))
                Text(formatInterval(interval))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isAdd ? .green : .red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isAdd ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func formatInterval(_ value: Double) -> String {
        if value >= 1 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    IntervalInputView(amount: .constant(25))
}
