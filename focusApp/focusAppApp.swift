import SwiftUI

@main
struct focusAppApp: App {
    // Create the coordinator
    @StateObject private var coordinator = AppCoordinator()
    
    // MARK: - FIX 1: Create the StatsManager here
    // This single instance will be shared across your entire app.
    @StateObject private var statsManager = StatsManager()

    var body: some Scene {
        WindowGroup {
            // The switch statement controls which view is visible
            switch coordinator.currentView {
            case .home:
                HomeView()
                    .environmentObject(coordinator)
                    // Note: HomeView probably doesn't need stats, but it's harmless to add.
                    .environmentObject(statsManager)

            case .alertMode:
                AlertModeView()
                    .environmentObject(coordinator)
                    // MARK: - FIX 2: Inject StatsManager into AlertModeView
                    .environmentObject(statsManager)

            case .quietMode:
                QuietModeView()
                    .environmentObject(coordinator)
                    // MARK: - FIX 3: Inject StatsManager into QuietModeView
                    .environmentObject(statsManager)

            case .summary:
                // Ensure you have access to the last completed session here.
                // This is an example, you'll need to adapt it to how your app stores this.
                if let lastSession = statsManager.lastCompletedSession { // <--- Get the session here
                    SummaryView(session: lastSession) // <--- Pass the session
                        .environmentObject(coordinator)
                        .environmentObject(statsManager)
                } else {
                    // Handle the case where there's no last completed session,
                    // perhaps show an error or navigate back to home.
                    Text("No session data available.")
                        .environmentObject(coordinator)
                        .environmentObject(statsManager)
                        
                }

            case .history:
                HistoryView()
                    .environmentObject(coordinator)
                    // MARK: - FIX 5: Inject StatsManager into HistoryView
                    // The history view will also need this.
                    .environmentObject(statsManager)
            
            
            }
        }
    }
}
