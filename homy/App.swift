import SwiftUI
import SwiftData

@main
struct MyApp: App {
    // Create the ModelContainer for SwiftData models and inject into environment
    let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: [Device.self, Entity.self])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
