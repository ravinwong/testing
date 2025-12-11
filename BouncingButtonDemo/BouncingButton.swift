import UIKit

/// A custom round button that bounces when pressed
class BouncingButton: UIButton {

    // MARK: - Properties

    /// The color of the button
    var buttonColor: UIColor = .systemBlue {
        didSet {
            updateAppearance()
        }
    }

    /// The bounce scale factor (default is 0.85)
    var bounceScale: CGFloat = 0.85

    /// The bounce duration (default is 0.15 seconds)
    var bounceDuration: TimeInterval = 0.15

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    convenience init(title: String, color: UIColor = .systemBlue) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
        self.buttonColor = color
        updateAppearance()
    }

    // MARK: - Setup

    private func setupButton() {
        // Make the button round
        layer.masksToBounds = true

        // Set default appearance
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        // Add touch event handlers
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        updateAppearance()
    }

    private func updateAppearance() {
        backgroundColor = buttonColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep the button circular
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Animation

    @objc private func buttonTouchDown() {
        animateBounce(scale: bounceScale)
    }

    @objc private func buttonTouchUp() {
        animateBounce(scale: 1.0)
    }

    private func animateBounce(scale: CGFloat) {
        UIView.animate(
            withDuration: bounceDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, scaleY: scale)
            },
            completion: nil
        )
    }
}

// MARK: - Usage Example

/*
 // Example 1: Programmatic creation
 let bouncingButton = BouncingButton(title: "Tap Me!", color: .systemBlue)
 bouncingButton.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
 bouncingButton.center = view.center
 bouncingButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
 view.addSubview(bouncingButton)

 // Example 2: Customize bounce properties
 let customButton = BouncingButton()
 customButton.setTitle("Custom", for: .normal)
 customButton.buttonColor = .systemPurple
 customButton.bounceScale = 0.9  // Less dramatic bounce
 customButton.bounceDuration = 0.2  // Slower animation
 customButton.frame = CGRect(x: 100, y: 100, width: 120, height: 120)
 view.addSubview(customButton)

 // Example 3: Using in Storyboard/XIB
 // 1. Add a UIButton to your storyboard
 // 2. Set the class to "BouncingButton" in the Identity Inspector
 // 3. The button will automatically be round and bouncy
 */
