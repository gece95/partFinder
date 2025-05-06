import SwiftUI

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
        NavigationView {
            Form {
                Section(header: Text("Description")) {
                    TextField("Description", text: $description)
                }
                Section(header: Text("Price")) {
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Condition")) {
                    Picker("Condition", selection: $condition) {
                        Text("New").tag("new")
                        Text("Used").tag("used")
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Edit Listing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateListing(listingID: listing.id, category: listing.typeOfPart.lowercased(), newDescription: description, newPrice: price, newCondition: condition)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
