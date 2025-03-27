//
//  ListingListView.swift
//  partFinder
//
//  Created by Gerardo Cervantes on 3/25/25.
//


import SwiftUI

struct ListingListView: View {
    let title: String
    let listings: [Listing]

    var body: some View {
        List(listings, id: \.id) { listing in
            NavigationLink(destination: ListingViewDetail(listing: listing)) {
                VStack(alignment: .leading) {
                    Text(listing.title)
                        .font(.headline)
                    Text("$\(listing.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle(title)
    }
}
