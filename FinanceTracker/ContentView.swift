import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        Group {
            if profileManager.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FinanceManager())
        .environmentObject(ProfileManager())
}
