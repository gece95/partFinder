<<<<<<< HEAD

 import SwiftUI
=======
import SwiftUI
import PhotosUI
>>>>>>> develop

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingEditSheet = false
    @State private var isUploading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            if let image = viewModel.profileUIImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .offset(x: -5, y: -5)
                            .onChange(of: selectedItem) { newItem in
                                if let newItem = newItem {
                                    Task {
                                        do {
                                            if let data = try await newItem.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                isUploading = true
                                                viewModel.uploadProfileImage(uiImage) { _ in
                                                    isUploading = false
                                                }
                                            }
                                        } catch {
                                            print("Failed to load image data: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }

                        Text(viewModel.userEmail)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(viewModel.userLocation)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

                    if isUploading {
                        ProgressView("Uploading...").padding(.bottom)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transactions")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.horizontal)

                        ProfileRowItem(icon: "cart.fill", text: "Purchases & Sales")
                        ProfileRowItem(icon: "creditcard.fill", text: "Payment & Deposit Methods")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Account")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.horizontal)

                        Button(action: {
                            showingEditSheet = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.blue)
                                Text("Account Settings")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.black)
                        }

                        Button(action: {
                            viewModel.logout {
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Logout")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitle("Profile", displayMode: .inline)
            .sheet(isPresented: $showingEditSheet) {
                ProfileEditSection(viewModel: viewModel)
            }
        }
    }
}

<<<<<<< HEAD


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


=======
>>>>>>> develop
