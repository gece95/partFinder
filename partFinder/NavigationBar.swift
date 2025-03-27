//
//  NavigationBar.swift
//  partFinder
//
//  Created by Zoe Hazan on 3/26/25.
//
import SwiftUI

struct BottomNavBar: View {
    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: vendorView()) {
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                    Text("Sell")
                        .font(.caption)
                }
            }
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "house")
                    .font(.system(size: 20))
                Text("Home")
                    .font(.caption)
            }
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "person")
                    .font(.system(size: 20))
                Text("Profile")
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.black)
        .foregroundColor(.gray)
    }
}

struct BaseView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
                    VStack(spacing: 0) {  // Ensures no extra spacing
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fills available space
                            .background(Color(.systemBackground)) // Ensure background fills gaps
                        
                        BottomNavBar()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .navigationBarHidden(true)
            }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar()
    }
}
