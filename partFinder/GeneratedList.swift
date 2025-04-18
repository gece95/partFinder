//
//  GeneratedList.swift
//  partFinder
//
//  Created by Zoe Hazan on 3/11/25.
//

import Foundation
import SwiftUI

// View for displaying part listings
struct PartListingsView: View {
    var partType: String
    @State private var priceFilter: Double = 5000.0
    
    // Compute the filtered list separately
    var filteredListings: [Listing] {
        dummyListings.filter { listing in
            listing.partType == partType && listing.price <= priceFilter
        }
    }
    // Defines the body of the view
    var body: some View {
            // Enables vertical scrolling
            ScrollView {
                VStack {
                    // Title for the listings
                    Text("Available \(partType) Listings:")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.horizontal)
                    
                    // Section for price filtering
                    VStack {
                        Text("\nFilter by Maximum Price: $\(priceFilter, specifier: "%.2f")")
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Slider for adjusting the price filter dynamically
                        Slider(value: $priceFilter, in: 0...5000, step: 50)
                            .padding(.horizontal)
                            .padding(.top, 5)
                    }
                    .padding(.horizontal)
                    
                    // LazyVStack for displaying the filtered listings efficiently
                    LazyVStack(spacing: 15) {
                        // Iterates through the filtered listings and displays each one
                        ForEach(filteredListings, id: \.id) { listing in
                            NavigationLink(destination: ListingViewDetail(listing: listing)) { // Clicking navigates to ListingView
                                VStack(alignment: .leading) {
                                    // Displays the part title and price
                                    Text("\(listing.title) - $\(listing.price, specifier: "%.2f")")
                                        .font(.headline)
                                        .bold()
                                        .padding(.bottom, 5)
                                        .foregroundColor(Color.white)
                                    
                                    // Displays vehicle make, model, year, and trim associated with the part
                                    Text("Make: \(listing.make), Model: \(listing.model), Year: \(listing.year)")
                                        .padding(.bottom, 5)
                                        .foregroundColor(Color.white)
                                    
                                    Text("Trim: \(listing.trim)")
                                        .padding(.bottom, 5)
                                        .foregroundColor(Color.white)
                                         
                                    // Displays the city where the part is located
                                    Text("City: \(listing.city)")
                                        .padding(.bottom, 5)
                                        .foregroundColor(Color.white)
                                    
                                    // Displays the seller's contact phone number
                                    Text("Contact: \(listing.phoneNumber)")
                                        .padding(.bottom, 5)
                                        .foregroundColor(Color.white)
                                    
                                    // Displays a description of the listing
                                    Text("Description: \(listing.description)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.bottom, 10)
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
            }
            .background(Color.black)
            .ignoresSafeArea()
            .onAppear {
                            let appearance = UINavigationBarAppearance()
                            appearance.configureWithOpaqueBackground()
                            appearance.backgroundColor = UIColor.black // Match background color
                            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                            UINavigationBar.appearance().standardAppearance = appearance
                            UINavigationBar.appearance().scrollEdgeAppearance = appearance
                            UINavigationBar.appearance().compactAppearance = appearance
                            UINavigationBar.appearance().tintColor = .white // Back button color
            }
        }
    }
}

