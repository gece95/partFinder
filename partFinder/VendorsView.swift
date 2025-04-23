import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseDatabase
import PhotosUI

struct Posting: Identifiable, Hashable, Codable {
    var id = UUID()
    var phoneNumber: String
    var description: String
    var price: String
    var condition: String
    var typeOfPart: String
    var imageUrls: [String]
}

struct VendorsView: View {
    @AppStorage("userUID") var userUID: String = ""

    @State private var phoneNumber = ""
    @State private var description = ""
    @State private var price = ""
    @State private var isUsed = false
    @State private var selectedType = ""
    @State private var selectedImages: [UIImage] = []
    @State private var imageSelections: [PhotosPickerItem] = []

    @State private var errorMessage = ""
    @State private var isUploading = false

    let partTypes = ["Engine", "Turbocharger", "Fluids", "Gaskets", "Brakes", "Batteries"]

    var body: some View {
        NavigationView {
            BaseView {
                ZStack {
                    // Background Image with Dark Overlay
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
                    
                    VStack(spacing: 12) {
                        Text("Sell")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                
                                // Images Scroll Section
                                if !selectedImages.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(selectedImages, id: \.self) { image in
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 150)
                                                    .clipped()
                                                    .border(Color.gray, width: 1)
                                                    .cornerRadius(10)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Image Picker
                                PhotosPicker(
                                    selection: $imageSelections,
                                    maxSelectionCount: 5,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    Label("Add Images", systemImage: "photo.on.rectangle.angled").foregroundColor(.white)
                                }
                                .onChange(of: imageSelections) {
                                    
                                    selectedImages = []
                                    Task {
                                        for item in imageSelections {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                selectedImages.append(uiImage)
                                            }
                                        }
                                    }
                                }
                                
                                // Text Inputs
                                Group {
                                    TextField("Phone Number", text: $phoneNumber)
                                        .keyboardType(.phonePad)
                                    
                                    TextEditor(text: $description)
                                        .frame(height: 120)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    TextField("Price (e.g. 25.00)", text: $price)
                                        .keyboardType(.decimalPad)
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                
                                // Toggle for Condition
                                HStack {
                                    Text("Condition:")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .bold()

                                    Spacer()

                                    Toggle(isOn: $isUsed) {
                                        Text(isUsed ? "Used" : "New")
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                
                                // Error Message
                                if !errorMessage.isEmpty {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }
                                
                                // Submit Button
                                Button(action: {
                                    submitListing()
                                }) {
                                    Text(isUploading ? "Submitting..." : "Submit Listing")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isUploading ? Color.gray : Color.blue)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                }
                                .disabled(isUploading)
                                .padding(.horizontal)
                                
                            }
                            .padding(.bottom, 32)
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
    }

    func submitListing() {
        // Validation
        guard !phoneNumber.isEmpty,
              !description.isEmpty,
              !price.isEmpty,
              !selectedType.isEmpty,
              !selectedImages.isEmpty,
              Double(price) != nil else {
            errorMessage = "Please complete all fields correctly and add at least one image."
            return
        }

        errorMessage = ""
        isUploading = true

        uploadImagesToFirebase(images: selectedImages) { imageUrls in
            let newPost = Posting(
                phoneNumber: phoneNumber,
                description: description,
                price: price,
                condition: isUsed ? "Used" : "New",
                typeOfPart: selectedType,
                imageUrls: imageUrls
            )

            let ref = Database.database().reference()
            ref.child("listings").child(selectedType.lowercased()).childByAutoId().setValue([
                "phoneNumber": newPost.phoneNumber,
                "description": newPost.description,
                "price": newPost.price,
                "condition": newPost.condition,
                "typeOfPart": newPost.typeOfPart,
                "imageUrls": imageUrls
            ]) { error, _ in
                if let error = error {
                    errorMessage = "Upload failed: \(error.localizedDescription)"
                } else {
                    errorMessage = "✅ Listing uploaded successfully!"
                    clearForm()
                }
                isUploading = false
            }
        }
    }

    func clearForm() {
        phoneNumber = ""
        description = ""
        price = ""
        isUsed = false
        selectedType = ""
        selectedImages = []
    }

    func uploadImagesToFirebase(images: [UIImage], completion: @escaping ([String]) -> Void) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()

        for image in images {
            group.enter()
            let imageName = UUID().uuidString + ".jpg"
            let ref = Storage.storage().reference().child("listing_images/\(imageName)")

            if let imageData = image.jpegData(compressionQuality: 0.8) {
                ref.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("❌ Error uploading image: \(error)")
                        group.leave()
                        return
                    }

                    ref.downloadURL { url, _ in
                        if let url = url {
                            uploadedURLs.append(url.absoluteString)
                        }
                        group.leave()
                    }
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }
}

struct VendorsView_Previews: PreviewProvider {
    static var previews: some View {
        VendorsView()
    }
}

