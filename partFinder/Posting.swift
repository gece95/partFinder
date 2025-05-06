import Foundation

struct Posting: Identifiable, Equatable {
    var id: String
    var phoneNumber: String
    var description: String
    var price: String
    var condition: String
    var typeOfPart: String
    var imageUrls: [String]
}
