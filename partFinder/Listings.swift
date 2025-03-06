//
//  Listings.swift
//  partFinder
//
//  Created by Salma Ramirez on 3/4/25.
//

class Listings{
    var firstName = ""
    var lastName = ""
    var email = ""
    var phoneNumber = ""
    var address = ""
    var description = ""
    var price = 0.0
    var category = ""
    var imageURL = ""
    
    init(firstName: String = "", lastName: String = "", email: String = "", phoneNumber: String = "", address: String = "", description: String = "", price: Double = 0.0, category: String = "", imageURL: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.description = description
        self.price = price
        self.category = category
        self.imageURL = imageURL
    }
}

var jhondoe = Listings(firstName: "john", lastName: "doe", email: "jujuonthatbeat@hotmail.com")
