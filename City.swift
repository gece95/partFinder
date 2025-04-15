struct City: Codable, Identifiable, Hashable {
    var id: Int { name.hashValue }
    let name: String
}
