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
        ZStack {
            
            GeometryReader { geometry in
                ZStack {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
            
            
            if isLoggedIn {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Profile")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            
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
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        
                        if isUploading {
                            ProgressView("Uploading...").padding(.bottom)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Transactions")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.blue)
                                Text("Purchases & Sales")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            Button(action: {
                                showPaymentSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.blue)
                                    Text("Payment & Deposit Methods")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Account")
                                .fontWeight(.bold)
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
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
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
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
