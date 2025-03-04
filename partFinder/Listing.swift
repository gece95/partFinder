//
//  Listing.swift
//  partFinder
//
//  Created by Zoe Hazan on 3/4/25.
//

import Foundation

class Listing {
    var title = ""
    var partType = "" // Battery, brakes, etc.
    var make = ""
    var model = ""
    var year = ""
    var trim = ""
    var price = 0.0
    var description = ""
    var city = ""
    var phoneNumber = ""
    
    init(title: String, partType: String, make: String, model: String, year: String, trim: String, price: Double, description: String, city: String, phoneNumber: String) {
        self.title = title
        self.partType = partType // Battery, brakes, etc.
        self.make = make
        self.model = model
        self.year = year
        self.trim = trim
        self.price = price
        self.description = description
        self.city = city
        self.phoneNumber = phoneNumber
    }
}
