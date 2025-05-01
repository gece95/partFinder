import SwiftUI

struct EditListingView: View {
    var listing: Posting
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Text("Edit Listing")
                .font(.title)
            Text("Description: \(listing.description)")
        }
        .padding()
    }
}
