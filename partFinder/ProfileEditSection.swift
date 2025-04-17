import SwiftUI
import FirebaseAuth

struct ProfileEditSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var newEmail: String
    @Binding var currentPassword: String
    @Binding var errorMessage: String
    @Binding var showAlert: Bool

    var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 15) {
            // Profile Image Preview
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            // Select Image Button
            Button("Select Profile Picture") {
                showImagePicker.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            // Upload Image Button
            Button("Upload Profile Picture") {
                if let image = selectedImage {
                    viewModel.uploadProfileImage(image) { url in
                        if url != nil {
                            errorMessage = "Profile image uploaded!"
                        } else {
                            errorMessage = "Failed to upload image"
                        }
                        showAlert = true
                    }
                } else {
                    errorMessage = "No image selected"
                    showAlert = true
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            Divider().background(Color.white)

            // Email Field (just UI — no backend logic)
            TextField("New Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Current Password", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Placeholder Update Button (no backend function)
            Button("Update Email") {
                errorMessage = "Update email feature not implemented yet."
                showAlert = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

