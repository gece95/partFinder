//
//  ListingViewDetail.swift
//  partFinder
//
//  Created by Salma Ramirez on 3/9/25.
//

import Foundation
// ListingView.swift
import SwiftUI

struct ListingView: View {
    var listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Add image at the top
            Image(listing.make) // Assuming you have an image named after the make, e.g., "Ford", "Toyota"
                .resizable()
                .scaledToFit()
                .frame(height: 200) // Adjust height as necessary
                .cornerRadius(10)
                .padding(.bottom, 10)

            // Title of the listing
            Text(listing.title)
                .font(.title)
                .bold()
                .foregroundColor(.white)

            // Price
            Text("Price: $\(listing.price, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.green)

            // Make, Model, Year, Trim
            Text("Make: \(listing.make), Model: \(listing.model), Year: \(listing.year), Trim: \(listing.trim)")
                .font(.subheadline)
                .foregroundColor(.white)

            // Description section
            Text("Description:")
                .font(.headline)
                .foregroundColor(.white)

            Text(listing.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)

            // Location
            Text("Location: \(listing.city)")
                .font(.subheadline)
                .foregroundColor(.white)

            // Contact
            Text("Contact: \(listing.phoneNumber)")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ListingView_Previews: PreviewProvider {
    static var previews: some View {
        ListingView(listing: dummyListings[0])
    }
}
