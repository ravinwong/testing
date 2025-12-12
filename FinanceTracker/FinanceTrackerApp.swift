import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var financeManager = FinanceManager()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(financeManager)
                .environmentObject(profileManager)
        }
    }
}
