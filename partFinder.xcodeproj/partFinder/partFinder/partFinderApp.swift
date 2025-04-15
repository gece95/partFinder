//
//  partFinderApp.swift
//  partFinder
//
//  Created by Gerardo Cervantes on 2/5/25.
//

import SwiftUI
import FirebaseCore

      

@main
struct partFinderApp: App {
    init() {
        FirebaseApp.configure()
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
