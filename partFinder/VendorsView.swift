import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseDatabase
import PhotosUI
import Foundation

struct VendorsView: View {
    @AppStorage("userUID") var userUID: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false


    @State private var phoneNumber = ""
    @State private var description = ""
    @State private var price = ""
    @State private var isUsed = false
    @State private var selectedType = ""
    @State private var selectedImages: [UIImage] = []
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var showAuthView = false

    @State private var errorMessage = ""
    @State private var isUploading = false

    let partTypes = ["Engine", "Turbocharger", "Fluids", "Gaskets", "Brakes", "Batteries"]

    var body: some View {
        NavigationView {
            BaseView {
                if isLoggedIn {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        VStack(spacing: 12) {
                            Text("Sell")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            ScrollView {
                                VStack(spacing: 16) {
                                    
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
                                    
                                    PhotosPicker(
                                        selection: $imageSelections,
                                        maxSelectionCount: 5,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        Label("Add Images", systemImage: "photo.on.rectangle.angled")
                                    }
                                    .onChange(of: imageSelections) { newSelections in
                                        selectedImages = []
                                        Task {
                                            for item in newSelections {
                                                if let data = try? await item.loadTransferable(type: Data.self),
                                                   let uiImage = UIImage(data: data) {
                                                    selectedImages.append(uiImage)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Menu {
                                        ForEach(partTypes, id: \.self ) { type in
                                            Button(type) { selectedType = type }
                                        }
                                    } label: {
                                        dropdownLabel(text: selectedType, placeholder: "Select Part Type")
                                    }
                                    .padding(.horizontal)
                                    
                                    Group {
                                        TextField("Phone Number", text: $phoneNumber)
                                            .keyboardType(.numberPad)
                                            .onChange(of: phoneNumber) { newVal in
                                                phoneNumber = formatPhoneNumber(newVal)
                                            }
                                        
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
                                    
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            isUsed = false
                                        }) {
                                            Text("New")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(!isUsed ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }

                                        Button(action: {
                                            isUsed = true
                                        }) {
                                            Text("Used")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(isUsed ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding(.horizontal)
                                        
                                    
                                    if !errorMessage.isEmpty {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                            .padding(.horizontal)
                                    }
                                    
                                    Button(action: {
                                        submitListing()
                                    }) {
                                        Text(isUploading ? "Submitting..." : "Submit Listing")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(isUploading ? Color.gray : Color.blue)
                                            .foregroundColor(.white)
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
                } else {
                    VStack(spacing: 20) {
                        Text("Please log in to post a listing.")
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAuthView) {
            AuthView()
        }
    }

    func dropdownLabel(text: String, placeholder: String) -> some View {
        HStack {
            Text(text.isEmpty ? placeholder : text)
                .foregroundColor(text.isEmpty ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    func submitListing() {
        guard !phoneNumber.isEmpty,
              !description.isEmpty,
              !price.isEmpty,
              !selectedType.isEmpty,
              !selectedImages.isEmpty,
              Double(price) != nil,
              description.count >= 10 && description.count <= 1000 else {
            errorMessage = "Please complete all fields correctly."
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

            // Save to public category
            ref.child("listings").child(selectedType.lowercased()).childByAutoId().setValue([
                "phoneNumber": newPost.phoneNumber,
                "description": newPost.description,
                "price": newPost.price,
                "condition": newPost.condition,
                "typeOfPart": newPost.typeOfPart,
                "imageUrls": newPost.imageUrls
            ])

            // Save to user's myListings
            ref.child("users").child(userUID).child("myListings").childByAutoId().setValue([
                "phoneNumber": newPost.phoneNumber,
                "description": newPost.description,
                "price": newPost.price,
                "condition": newPost.condition,
                "typeOfPart": newPost.typeOfPart,
                "imageUrls": newPost.imageUrls
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

    func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        if digits.count >= 10 {
            let area = digits.prefix(3)
            let mid = digits.dropFirst(3).prefix(3)
            let end = digits.dropFirst(6).prefix(4)
            return "(\(area)) -\(mid)-\(end)"
        }
        return digits
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
                            print("✅ Uploaded Image URL:", url.absoluteString)
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
