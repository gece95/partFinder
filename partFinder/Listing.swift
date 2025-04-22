//
//  Listing.swift
//  partFinder
//
//  Created by Zoe Hazan on 3/4/25.
//

/*import Foundation


// Defines a Listing class representing a vehicle part listing
// Each listing has an identifier, part details, and contact information
// Make the class public to allow access from other files
public class Listing: Identifiable {
    public let id = UUID()
    public var title: String
    public var partType: String  // Battery, brakes, etc.
    public var make: String
    public var model: String
    public var year: String
    public var trim: String
    public var price: Double
    public var description: String
    public var sellerFullName: String = ""
    public var city: String
    public var phoneNumber: String
    
    // Public initializer to allow instances from other files
    public init(title: String, partType: String, make: String, model: String, year: String, trim: String, price: Double, description: String, sellerFullName: String, city: String, phoneNumber: String) {
        self.title = title
        self.partType = partType
        self.make = make
        self.model = model
        self.year = year
        self.trim = trim
        self.price = price
        self.description = description
        self.sellerFullName = sellerFullName
        self.city = city
        self.phoneNumber = phoneNumber
    }
}

let dummyListings: [Listing] = [
    Listing(title: "V8 Engine", partType: "Engine", make: "Ford", model: "Mustang", year: "2019", trim: "GT", price: 3500.0, description: "High-performance V8 engine in excellent condition.", sellerFullName: "John Doe", city: "Los Angeles", phoneNumber: "123-456-7890"),
    Listing(title: "Turbocharged Engine", partType: "Engine", make: "Subaru", model: "WRX", year: "2020", trim: "STI", price: 4200.0, description: "Low-mileage turbocharged engine, perfect for performance builds.", sellerFullName: "Jane Smith", city: "Denver", phoneNumber: "987-654-3210"),
    Listing(title: "Hybrid Engine", partType: "Engine", make: "Toyota", model: "Prius", year: "2021", trim: "LE", price: 2800.0, description: "Eco-friendly hybrid engine, great for fuel efficiency.", sellerFullName: "Michael Johnson", city: "San Francisco", phoneNumber: "555-123-4567"),
    Listing(title: "Supercharged V6", partType: "Engine", make: "Jaguar", model: "F-Type", year: "2018", trim: "R-Dynamic", price: 5000.0, description: "Powerful supercharged V6 engine, ready for installation.", sellerFullName: "Emily Davis", city: "Chicago", phoneNumber: "111-222-3333"),
    Listing(title: "V8 Engine", partType: "Engine", make: "Ford", model: "Mustang", year: "2019", trim: "GT", price: 3500.0, description: "High-performance V8 engine in excellent condition.", sellerFullName: "David Wilson", city: "Los Angeles", phoneNumber: "123-456-7890"),
    Listing(title: "Turbocharged Engine", partType: "Engine", make: "Subaru", model: "WRX", year: "2020", trim: "STI", price: 4200.0, description: "Low-mileage turbocharged engine, perfect for performance builds.", sellerFullName: "Sophia Martinez", city: "Denver", phoneNumber: "987-654-3210"),
    Listing(title: "Hybrid Engine", partType: "Engine", make: "Toyota", model: "Prius", year: "2021", trim: "LE", price: 2800.0, description: "Eco-friendly hybrid engine, great for fuel efficiency.", sellerFullName: "James Brown", city: "San Francisco", phoneNumber: "555-123-4567"),
    Listing(title: "Supercharged V6", partType: "Engine", make: "Jaguar", model: "F-Type", year: "2018", trim: "R-Dynamic", price: 5000.0, description: "Powerful supercharged V6 engine, ready for installation.", sellerFullName: "Olivia Taylor", city: "Chicago", phoneNumber: "111-222-3333")
]
*/
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
