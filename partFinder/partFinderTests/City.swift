//
//  City.swift
//  partFinder
//
//  Created by Emily marrufo on 3/25/25.
// new testing out to call an API of cities instead of manually importing it


struct City: Codable, Identifiable, Hashable {
    var id: Int { name.hashValue }
    let name: String
}
