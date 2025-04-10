import Foundation
// ListingView.swift
import SwiftUI

struct ListingViewDetail: View {
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

            Text(listing.title)
                .font(.title)
                .bold()
                .foregroundColor(.white)

            Text("Price: $\(listing.price, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.green)

            Text("Make: \(listing.make), Model: \(listing.model), Year: \(listing.year), Trim: \(listing.trim)")
                .font(.subheadline)
                .foregroundColor(.white)

            Text("Description:")
                .font(.headline)
                .foregroundColor(.white)

            Text(listing.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)

            Text("Location: \(listing.city)")
                .font(.subheadline)
                .foregroundColor(.white)

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

