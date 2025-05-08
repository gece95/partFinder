import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct EditListingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProfileViewModel

    @State var description: String
    @State var price: String
    @State var condition: String

    let listing: Posting

    init(listing: Posting, viewModel: ProfileViewModel) {
        self.listing = listing
        self.viewModel = viewModel
        _description = State(initialValue: listing.description)
        _price = State(initialValue: listing.price)
        _condition = State(initialValue: listing.condition)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Edit Listing")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.top)

                TextField("Description", text: $description)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black)

                TextField("Price (e.g. 25.00)", text: $price)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black)

                HStack {
                    Button(action: {
                        condition = "New"
                    }) {
                        Text("New")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(condition.lowercased() == "new" ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        condition = "Used"
                    }) {
                        Text("Used")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(condition.lowercased() == "used" ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                }

                Button("Save Changes") {
                    viewModel.updateListing(
                        listingID: listing.id,
                        category: listing.typeOfPart.lowercased(),
                        newDescription: description,
                        newPrice: price,
                        newCondition: condition
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.gray)
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
    }
}
