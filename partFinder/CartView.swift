import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() 

            ScrollView {
                VStack(spacing: 16) {
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
                                    ProgressView()
                                        .frame(height: 150)
                                }
                            }

                            Text(post.description)
                                .foregroundColor(.white)
                            Text("Price: $\(post.price)")
                                .foregroundColor(.blue)
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
                .padding()
            }
        }
        .navigationTitle("My Cart")
    }
}
