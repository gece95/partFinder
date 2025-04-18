//
//  Listing.swift
//  partFinder
//
//  Created by Zoe Hazan on 3/4/25.
//

import Foundation


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

