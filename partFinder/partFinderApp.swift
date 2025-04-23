/*import SwiftUI
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
*/
import SwiftUI
import FirebaseCore
import UIKit

// MARK: - AppDelegate for Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Set black background for tab bar globally
        let appearance = UITabBar.appearance()
        appearance.barTintColor = .black
        appearance.backgroundColor = .black
        appearance.unselectedItemTintColor = .gray
        appearance.tintColor = .blue // active tab icon/text color
        
        return true
    }
}

// MARK: - Main App Struct
@main
struct partFinderApp: App {
    // Inject the AppDelegate into SwiftUI app lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
