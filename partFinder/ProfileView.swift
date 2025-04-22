import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @State private var showAuthView = false
    @State private var showPaymentSheet = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingEditSheet = false
    @State private var isUploading = false
    
    var body: some View {
        BaseView(title: "Profile") {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    if isLoggedIn {
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
                                        .onChange(of: selectedItem) {
                                            guard let newItem = selectedItem else { return }
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
                                    
                                    Text(viewModel.userEmail)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(viewModel.userLocation)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                
                                if isUploading {
                                    ProgressView("Uploading...").padding(.bottom)
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Transactions")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                    
                                    ProfileRowItem(icon: "cart.fill", text: "Purchases & Sales")
                                    
                                    // Payment Methods Button
                                    Button(action: {
                                        showPaymentSheet = true
                                    }) {
                                        ProfileRowItem(icon: "creditcard.fill", text: "Payment & Deposit Methods")
                                    }
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
                                            isLoggedIn = false
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
                    } else {
                        VStack(spacing: 20) {
                            Text("Please log in to access your profile")
                                .foregroundColor(.white)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Button("Login / Sign Up") {
                                showAuthView = true
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    ProfileEditSection(viewModel: viewModel)
                }
                .sheet(isPresented: $showAuthView) {
                    AuthView()
                }
                .sheet(isPresented: $showPaymentSheet) {
                    PaymentMethodsView()
                }
            }
        }
}
