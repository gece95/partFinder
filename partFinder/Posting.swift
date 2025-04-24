import Foundation

struct Posting: Identifiable, Codable, Hashable {
    var id = UUID()
    let phoneNumber: String
    let description: String
    let price: String
    let condition: String
    let typeOfPart: String
    let imageUrls: [String]
}
