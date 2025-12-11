import UIKit

class ViewController: UIViewController {

    private var tapCountLabel: UILabel!
    private var tapCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Bouncing Button Demo"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Tap the buttons below to see the bounce effect!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        // Create bouncing buttons with different colors
        let blueButton = BouncingButton(title: "Blue Button", color: .systemBlue)
        blueButton.translatesAutoresizingMaskIntoConstraints = false
        blueButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(blueButton)

        let purpleButton = BouncingButton(title: "Purple", color: .systemPurple)
        purpleButton.translatesAutoresizingMaskIntoConstraints = false
        purpleButton.bounceScale = 0.9  // Less dramatic bounce
        purpleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(purpleButton)

        let greenButton = BouncingButton(title: "Green", color: .systemGreen)
        greenButton.translatesAutoresizingMaskIntoConstraints = false
        greenButton.bounceScale = 0.8  // More dramatic bounce
        greenButton.bounceDuration = 0.2  // Slower animation
        greenButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(greenButton)

        let orangeButton = BouncingButton(title: "🔥", color: .systemOrange)
        orangeButton.translatesAutoresizingMaskIntoConstraints = false
        orangeButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        orangeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(orangeButton)

        // Tap count label
        tapCountLabel = UILabel()
        tapCountLabel.text = "Taps: 0"
        tapCountLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        tapCountLabel.textAlignment = .center
        tapCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tapCountLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Blue button (large)
            blueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blueButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 50),
            blueButton.widthAnchor.constraint(equalToConstant: 180),
            blueButton.heightAnchor.constraint(equalToConstant: 180),

            // Purple button (medium)
            purpleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -90),
            purpleButton.topAnchor.constraint(equalTo: blueButton.bottomAnchor, constant: 40),
            purpleButton.widthAnchor.constraint(equalToConstant: 120),
            purpleButton.heightAnchor.constraint(equalToConstant: 120),

            // Green button (medium)
            greenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 90),
            greenButton.topAnchor.constraint(equalTo: blueButton.bottomAnchor, constant: 40),
            greenButton.widthAnchor.constraint(equalToConstant: 120),
            greenButton.heightAnchor.constraint(equalToConstant: 120),

            // Orange button (small)
            orangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orangeButton.topAnchor.constraint(equalTo: purpleButton.bottomAnchor, constant: 40),
            orangeButton.widthAnchor.constraint(equalToConstant: 80),
            orangeButton.heightAnchor.constraint(equalToConstant: 80),

            // Tap count label
            tapCountLabel.topAnchor.constraint(equalTo: orangeButton.bottomAnchor, constant: 40),
            tapCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func buttonTapped(_ sender: BouncingButton) {
        tapCount += 1
        tapCountLabel.text = "Taps: \(tapCount)"

        // Add a little haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
