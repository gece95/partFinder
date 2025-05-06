import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showConfirmationMessage = false

    var body: some View {
        NavigationView {
            BaseView {
                ZStack {
                    Color.black.ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 16) {
                            Text("My Cart")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.top)

                            if cartManager.cartItems.isEmpty {
                                Text("Your cart is empty")
                                    .foregroundColor(.blue)
                                    .padding(.top, 50)
                            } else {
                                ForEach(cartManager.cartItems) { post in
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let url = URL(string: post.imageUrls.first ?? "") {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(height: 150)
                                                    .clipped()
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                ProgressView().frame(height: 150)
                                            }
                                        }

                                        Text(post.description)
                                            .foregroundColor(.white)
                                        Text("Price: $\(post.price)")
                                            .foregroundColor(.blue)

                                        Button("Confirm Delivery") {
                                            confirmDelivery(post)
                                        }
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.green)
                                        .cornerRadius(8)

                                        Button("Remove") {
                                            cartManager.removeFromCart(post)
                                        }
                                        .foregroundColor(.red)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .alert(isPresented: $showConfirmationMessage) {
                    Alert(
                        title: Text("Confirmed"),
                        message: Text("Thank you for confirming."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    func confirmDelivery(_ post: Posting) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let category = post.typeOfPart.lowercased()

        ref.child("listings").child(category).child(post.id).removeValue { error, _ in
            if let error = error {
                print("❌ Failed to remove listing from main listings: \(error.localizedDescription)")
            } else {
                print("✅ Listing removed from main listings.")

                ref.child("users").child(userUID).child("myListings").child(post.id).removeValue { error, _ in
                    if let error = error {
                        print("❌ Failed to remove listing from user's myListings: \(error.localizedDescription)")
                    } else {
                        print("✅ Listing removed from user's myListings.")
                        print("Thank you for confirming.")
                        cartManager.removeFromCart(post)
                    }
                }
            }
        }
        print("Thank you for confirming.")
        cartManager.removeFromCart(post)
        showConfirmationMessage = true
    }
}
