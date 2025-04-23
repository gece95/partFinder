//
//  ListingsPosting.swift
//  partFinder
//
//  Created by Salma Ramirez on 4/22/25.
//


import Foundation

struct Posting: Identifiable, Hashable, Codable {
    var id = UUID()
    var phoneNumber: String
    var description: String
    var price: String
    var condition: String
    var typeOfPart: String
    var imageUrls: [String]
}
