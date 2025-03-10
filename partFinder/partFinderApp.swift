//
//  partFinderApp.swift
//  partFinder
//
//  Created by Gerardo Cervantes on 2/5/25.
//

// Imports SwiftUI framework for building the app's UI
import SwiftUI
// Imports FirebaseCore to initialize Firebase services
import FirebaseCore

      
// Marks this struct as the entry point of the application
@main
struct partFinderApp: App {
    // Initializes Firebase when the app launches
    init() {
        // Configures Firebase services for use in the app
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
