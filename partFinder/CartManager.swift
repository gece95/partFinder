import Foundation

class CartManager: ObservableObject {
    @Published var cartItems: [Posting] = []

    func addToCart(_ item: Posting) {
        if !cartItems.contains(item) {
            cartItems.append(item)
        }
    }

    func removeFromCart(_ item: Posting) {
        cartItems.removeAll { $0.id == item.id }
    }
}
