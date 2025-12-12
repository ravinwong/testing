import Foundation
import SwiftUI

class ProfileManager: ObservableObject {
    @Published var profile: UserProfile = .empty
    @Published var hasCompletedOnboarding: Bool = false

    private let profileKey = "userProfile"
    private let onboardingKey = "hasCompletedOnboarding"

    init() {
        loadProfile()
    }

    // MARK: - Profile Management

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        saveProfile()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }

    // MARK: - Cost Estimates

    func estimatedCost(for category: ExpenseCategory) -> Double {
        profile.estimatedCosts[category] ?? 0
    }

    func roundedEstimate(for category: ExpenseCategory) -> Double {
        let estimate = estimatedCost(for: category)
        // Round to nearest appropriate interval based on amount
        if estimate < 5 {
            return (estimate).rounded()
        } else if estimate < 20 {
            return (estimate / 5).rounded() * 5
        } else if estimate < 50 {
            return (estimate / 10).rounded() * 10
        } else {
            return (estimate / 20).rounded() * 20
        }
    }

    // MARK: - Persistence

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }

    private func loadProfile() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)

        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        }
    }
}
