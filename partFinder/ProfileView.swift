import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()

    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var errorMessage = ""
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Profile Header
                VStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }

                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }

                    // Dynamic email from Firebase
                    Text(viewModel.userEmail)
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    // Optional Location (you can delete this if you want)
                    Text(viewModel.userLocation)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider().background(Color.gray)

                // Transactions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transactions")
                        .font(.headline)
                        .foregroundColor(.white)

                    ProfileRowItem(icon: "dollarsign.circle", label: "Purchases & Sales")
                    ProfileRowItem(icon: "creditcard", label: "Payment & Deposit Methods")
                }

                Divider().background(Color.gray)

                // Account Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account")
                        .font(.headline)
                        .foregroundColor(.white)

                    ProfileRowItem(icon: "gearshape", label: "Account Settings")

                    // Blue Logout Button with Icon
                    Button {
                        viewModel.logout()
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.left")
                            Text("Logout")
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

