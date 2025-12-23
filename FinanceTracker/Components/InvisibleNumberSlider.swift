import SwiftUI

/// An invisible slider that adjusts values through horizontal drag gestures.
/// - Sliding right triggers stop points at 1, 5, and 10 (adding to the value)
/// - Sliding left triggers stop points at -1, -5, and -10 (subtracting from the value)
/// - Haptic feedback is provided at each stop point
struct InvisibleNumberSlider: View {
    @Binding var value: Double

    /// Minimum allowed value (optional constraint)
    var minValue: Double? = nil

    /// Maximum allowed value (optional constraint)
    var maxValue: Double? = nil

    /// Callback when a stop point is triggered
    var onStopPointTriggered: ((Int) -> Void)? = nil

    // Stop point thresholds in points (pixels)
    private let stopPoints: [(threshold: CGFloat, change: Int)] = [
        (40, 1),    // First stop: ±1
        (100, 5),   // Second stop: ±5
        (180, 10)   // Third stop: ±10
    ]

    // Track the current drag state
    @State private var dragOffset: CGFloat = 0
    @State private var lastTriggeredIndex: Int = -1
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle()) // Makes the entire area tappable/draggable
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { gesture in
                            handleDragChanged(gesture.translation.width)
                        }
                        .onEnded { _ in
                            handleDragEnded()
                        }
                )
        }
    }

    private func handleDragChanged(_ translation: CGFloat) {
        dragOffset = translation

        let isPositive = translation > 0
        let absoluteOffset = abs(translation)

        // Find which stop point we're at
        var currentIndex = -1
        for (index, stopPoint) in stopPoints.enumerated() {
            if absoluteOffset >= stopPoint.threshold {
                currentIndex = index
            }
        }

        // If we've reached a new stop point, trigger it
        if currentIndex > lastTriggeredIndex {
            let change = stopPoints[currentIndex].change
            let actualChange = isPositive ? change : -change

            // Apply the change with constraints
            var newValue = value + Double(actualChange)
            if let min = minValue {
                newValue = max(min, newValue)
            }
            if let max = maxValue {
                newValue = min(max, newValue)
            }

            // Only trigger if value actually changes
            if newValue != value {
                value = newValue
                triggerHapticFeedback(forStopIndex: currentIndex)
                onStopPointTriggered?(actualChange)
            }

            lastTriggeredIndex = currentIndex
        }
    }

    private func handleDragEnded() {
        // Reset state for next drag
        dragOffset = 0
        lastTriggeredIndex = -1
    }

    private func triggerHapticFeedback(forStopIndex index: Int) {
        switch index {
        case 0:
            // Light feedback for ±1
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case 1:
            // Medium feedback for ±5
            feedbackGenerator.impactOccurred()
        case 2:
            // Heavy feedback for ±10
            heavyFeedbackGenerator.impactOccurred()
        default:
            break
        }
    }
}

// MARK: - Demo View for Live Simulation

/// A demo view showcasing the InvisibleNumberSlider functionality
struct InvisibleNumberSliderDemo: View {
    @State private var currentValue: Double = 50
    @State private var lastChange: Int = 0
    @State private var changeHistory: [ChangeRecord] = []
    @State private var showIndicator: Bool = false
    @State private var indicatorText: String = ""
    @State private var indicatorColor: Color = .blue

    struct ChangeRecord: Identifiable {
        let id = UUID()
        let change: Int
        let timestamp: Date
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                Text("Invisible Number Slider")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                // Instructions
                VStack(spacing: 8) {
                    Text("Swipe anywhere in the box below")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Right →", systemImage: "arrow.right")
                                .foregroundColor(.green)
                            Text("+1, +5, +10")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.8))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Label("← Left", systemImage: "arrow.left")
                                .foregroundColor(.red)
                            Text("-1, -5, -10")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Current value display
                VStack(spacing: 8) {
                    Text("Current Value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(Int(currentValue))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: currentValue)
                }

                // Change indicator
                if showIndicator {
                    Text(indicatorText)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(indicatorColor)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Invisible slider area with visual boundary
                ZStack {
                    // Dashed border to show the interactive area
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                        .foregroundColor(.gray.opacity(0.4))

                    // Distance markers
                    HStack {
                        // Left markers
                        VStack(spacing: 20) {
                            markerView(text: "-10", color: .red, opacity: 0.3)
                            markerView(text: "-5", color: .red, opacity: 0.5)
                            markerView(text: "-1", color: .red, opacity: 0.7)
                        }

                        Spacer()

                        // Center indicator
                        VStack {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("Drag here")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.5))
                        }

                        Spacer()

                        // Right markers
                        VStack(spacing: 20) {
                            markerView(text: "+10", color: .green, opacity: 0.3)
                            markerView(text: "+5", color: .green, opacity: 0.5)
                            markerView(text: "+1", color: .green, opacity: 0.7)
                        }
                    }
                    .padding(.horizontal, 20)

                    // The actual invisible slider
                    InvisibleNumberSlider(
                        value: $currentValue,
                        minValue: 0,
                        maxValue: 100,
                        onStopPointTriggered: { change in
                            handleChange(change)
                        }
                    )
                }
                .frame(height: 200)
                .padding(.horizontal)

                // Change history
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Changes")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(changeHistory.suffix(10)) { record in
                                Text(record.change > 0 ? "+\(record.change)" : "\(record.change)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(record.change > 0 ? .green : .red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        (record.change > 0 ? Color.green : Color.red)
                                            .opacity(0.15)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)

                // Reset button
                Button(action: resetDemo) {
                    Label("Reset to 50", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }

    private func markerView(text: String, color: Color, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(color.opacity(opacity))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(opacity * 0.2))
            .cornerRadius(6)
    }

    private func handleChange(_ change: Int) {
        lastChange = change

        // Show indicator
        withAnimation(.spring(response: 0.3)) {
            indicatorText = change > 0 ? "+\(change)" : "\(change)"
            indicatorColor = change > 0 ? .green : .red
            showIndicator = true
        }

        // Add to history
        changeHistory.append(ChangeRecord(change: change, timestamp: Date()))

        // Hide indicator after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                showIndicator = false
            }
        }
    }

    private func resetDemo() {
        withAnimation(.spring(response: 0.4)) {
            currentValue = 50
            changeHistory.removeAll()
        }
    }
}

// MARK: - Preview

#Preview("Invisible Slider Demo") {
    InvisibleNumberSliderDemo()
}

#Preview("Slider Only") {
    VStack {
        Text("Swipe horizontally below")
            .foregroundColor(.secondary)

        InvisibleNumberSlider(value: .constant(0))
            .frame(height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    .padding()
}
