import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct Listing: Identifiable, Codable, Hashable {
    let id: String
    let phoneNumber: String
    let description: String
    let price: String
    let condition: String
    let typeOfPart: String
    let imageUrls: [String]
}

struct ListingView: View {
    var partType: String

    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Listings...")
                        .padding()
                } else if listings.isEmpty {
                    Text("No listings available for \(partType).")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(listings) { listing in
                                VStack(alignment: .leading, spacing: 12) {
                                    if !listing.imageUrls.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(listing.imageUrls, id: \.self) { url in
                                                    AsyncImage(url: URL(string: url)) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView()
                                                                .frame(width: 150, height: 150)
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 150, height: 150)
                                                                .clipped()
                                                                .cornerRadius(8)
                                                                .border(Color.gray, width: 1)
                                                        case .failure:
                                                            Color.red
                                                                .frame(width: 150, height: 150)
                                                                .overlay(Text("Failed to load"))
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Price: $\(listing.price)")
                                            .font(.headline)
                                        Text("Condition: \(listing.condition)")
                                        Text("Contact: \(listing.phoneNumber)")
                                        Text(listing.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(partType) Listings")
            .onAppear {
                fetchListings()
            }
        }
    }

    private func fetchListings() {
        isLoading = true
        errorMessage = ""

        let ref = Database.database().reference()
        ref.child("listings").child(partType.lowercased()).observeSingleEvent(of: .value) { snapshot in
            var newListings: [Listing] = []
            for case let child as DataSnapshot in snapshot.children {
                if let dict = child.value as? [String: Any],
                   let phone = dict["phoneNumber"] as? String,
                   let desc = dict["description"] as? String,
                   let price = dict["price"] as? String,
                   let cond = dict["condition"] as? String,
                   let type = dict["typeOfPart"] as? String,
                   let urls = dict["imageUrls"] as? [String] {
                    let listing = Listing(
                        id: child.key,
                        phoneNumber: phone,
                        description: desc,
                        price: price,
                        condition: cond,
                        typeOfPart: type,
                        imageUrls: urls
                    )
                    newListings.append(listing)
                }
            }
            listings = newListings
            isLoading = false
        } withCancel: { error in
            errorMessage = "Failed to load listings: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
