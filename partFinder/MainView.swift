//
//  MainView.swift
//  partFinder
//
//  Created by Zoe Hazan on 4/22/25.
//

import Foundation
import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1 // 0: Sell, 1: Home, 2: Profile

    var body: some View {
        TabView(selection: $selectedTab) {
            VendorsView()
                .tag(0)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Sell")
                }

            ContentView()
                .tag(1)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ProfileView(viewModel: ProfileViewModel())
                .tag(2)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.blue) // Highlight selected tab in blue
        .tabViewStyle(DefaultTabViewStyle())
        .background(Color.black.ignoresSafeArea(edges: .bottom))

    }
}
