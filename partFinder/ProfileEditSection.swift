import SwiftUI
import PhotosUI

struct ProfileEditSection: View {
    @State private var newEmail: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading: Bool = false
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            PhotosPicker("Change Profile Picture", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { newItem in
                    if let newItem = newItem {
                        Task {
                            do {
                                if let data = try await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                    isUploading = true
                                    viewModel.uploadProfileImage(uiImage, completion: { url in
                                        isUploading = false
                                        print("Uploaded to: \(url?.absoluteString ?? "none")")
                                    })
                                }
                            } catch {
                                print("Failed to load image data: \(error.localizedDescription)")
                            }
                        }
                    }
                }

            if isUploading {
                ProgressView("Uploading...")
            }

            TextField("Enter new email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Update Email") {
                viewModel.updateEmail(to: newEmail) { error in
                    if let error = error {
                        print("Email update failed: \(error.localizedDescription)")
                    } else {
                        print("Email successfully updated")
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

