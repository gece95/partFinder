/*
 import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Dummy user data
    private let fullName = "Zoe Hazan"
    private let city = "Los Angeles"
    private let phoneNumber = "123-456-7890"
    
    // Dummy listings
    private let listings: [Listing] = [
        Listing(title: "Car Battery", partType: "Battery", make: "Toyota", model: "Corolla", year: "2020", trim: "LE", price: 150.0, description: "A high-quality car battery", sellerFullName: "Zoe Hazan", city: "Los Angeles", phoneNumber: "123-456-7890"),
        Listing(title: "Brake Pads", partType: "Brakes", make: "Honda", model: "Civic", year: "2018", trim: "EX", price: 80.0, description: "Reliable brake pads for Honda Civic", sellerFullName: "Zoe Hazan", city: "Los Angeles", phoneNumber: "123-456-7890"),
        Listing(title: "V8 Engine", partType: "Engine", make: "Ford", model: "Mustang", year: "2019", trim: "GT", price: 3500.0, description: "High-performance V8 engine", sellerFullName: "Zoe Hazan", city: "Los Angeles", phoneNumber: "123-456-7890")
    ]
    
    var body: some View {
        NavigationStack {
            BaseView {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                            .edgesIgnoringSafeArea(.all)
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Header (Centered)
                                Text("My Profile")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top)
                                
                                // User Info (Full Width)
                                VStack(spacing: 10) {
                                    Text("Name: \(fullName)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("City: \(city)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Contact: \(phoneNumber)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity) // Stretch across screen
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                
                                // Listings
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Your Listings")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    if !listings.isEmpty {
                                        showMyListings()
                                    }
                                }
                                
                                Spacer()
                                    .frame(height: geometry.safeAreaInsets.bottom)
                            }
                            .padding(.top)
                        }
                    }
                }
            }
        }
    }
    
    private func showMyListings() -> some View {
        ForEach(listings) { listing in
            VStack(alignment: .leading, spacing: 5) {
                Text(listing.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(listing.make) \(listing.model) (\(listing.year)) - $\(listing.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

*/
