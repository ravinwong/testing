import SwiftUI

/// A minimal view showing only a number that can be adjusted by dragging.
/// - Drag right: increases value (+1, +5, +10 at stop points)
/// - Drag left: decreases value (-1, -5, -10 at stop points)
struct InvisibleNumberSlider: View {
    @State private var value: Double = 0

    // Stop point thresholds in points
    private let stopPoints: [(threshold: CGFloat, change: Int)] = [
        (40, 1),
        (100, 5),
        (180, 10)
    ]

    @State private var lastTriggeredIndex: Int = -1

    var body: some View {
        Text("\(Int(value))")
            .font(.system(size: 120, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3), value: value)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { gesture in
                        handleDrag(gesture.translation.width)
                    }
                    .onEnded { _ in
                        lastTriggeredIndex = -1
                    }
            )
    }

    private func handleDrag(_ translation: CGFloat) {
        let isPositive = translation > 0
        let absoluteOffset = abs(translation)

        var currentIndex = -1
        for (index, stopPoint) in stopPoints.enumerated() {
            if absoluteOffset >= stopPoint.threshold {
                currentIndex = index
            }
        }

        if currentIndex > lastTriggeredIndex {
            let change = stopPoints[currentIndex].change
            let actualChange = isPositive ? change : -change

            value += Double(actualChange)
            triggerHaptic(forIndex: currentIndex)
            lastTriggeredIndex = currentIndex
        }
    }

    private func triggerHaptic(forIndex index: Int) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = switch index {
        case 0: .light
        case 1: .medium
        default: .heavy
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

#Preview {
    InvisibleNumberSlider()
}
