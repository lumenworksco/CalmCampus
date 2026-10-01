import SwiftData
import SwiftUI

@main
struct CalmCampusApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(health: HealthKitSignals())
        }
        .modelContainer(for: CheckinResponse.self)
    }
}
