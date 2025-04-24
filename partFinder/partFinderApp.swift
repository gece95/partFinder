import SwiftUI
import FirebaseCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct partFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var cartManager = CartManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartManager)
        }
    }
}
