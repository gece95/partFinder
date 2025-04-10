import SwiftUI
import FirebaseCore

      
// Marks this struct as the entry point of the application
@main
struct partFinderApp: App {
    // Initializes Firebase when the app launches
    init() {
        FirebaseApp.configure()
        
    }
    var body: some Scene {
        // Defines the main app scene
        WindowGroup {
            // Sets ContentView as the initial screen of the app
            ContentView()
        }
    }
}
