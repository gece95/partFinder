import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import Firebase
import FirebaseDatabase

class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var userLocation: String = ""
    @Published var profileUIImage: UIImage?
    @Published var myListings: [Posting] = []
    
    @Published var selectedListing: Posting? = nil
    @Published var showEditSheet: Bool = false
    


    init() {
        loadUserData()
    }
    func deleteListing(_ listing: Posting) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let category = listing.typeOfPart.lowercased()

        ref.child("listings").child(category).child(listing.id).removeValue()

        ref.child("users").child(userUID).child("myListings").child(listing.id).removeValue()

        DispatchQueue.main.async {
            self.myListings.removeAll { $0.id == listing.id }
        }
    }
    func updateListing(listingID: String, category: String, newDescription: String, newPrice: String, newCondition: String) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }

        let updatedData: [String: Any] = [
            "description": newDescription,
            "price": newPrice,
            "condition": newCondition
        ]

        let baseRef = Database.database().reference()

        let userRef = baseRef.child("users").child(userUID).child("myListings").child(listingID)
        let globalRef = baseRef.child("listings").child(category).child(listingID)

        userRef.updateChildValues(updatedData)
        globalRef.updateChildValues(updatedData)

        if let index = myListings.firstIndex(where: { $0.id == listingID }) {
            myListings[index].description = newDescription
            myListings[index].price = newPrice
            myListings[index].condition = newCondition
        }
    }
    func fetchMyListings(userUID: String) {
        let ref = Database.database().reference()
        ref.child("users").child(userUID).child("myListings").observeSingleEvent(of: .value) { snapshot in
            var fetched: [Posting] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let value = snap.value as? [String: Any],
                   let phone = value["phoneNumber"] as? String,
                   let desc = value["description"] as? String,
                   let price = value["price"] as? String,
                   let condition = value["condition"] as? String,
                   let type = value["typeOfPart"] as? String,
                   let imageUrls = value["imageUrls"] as? [String] {
                    let post = Posting(
                        id: snap.key,  // <-- capture Firebase key
                        phoneNumber: phone,
                        description: desc,
                        price: price,
                        condition: condition,
                        typeOfPart: type,
                        imageUrls: imageUrls
                    )
                    fetched.append(post)
                }
            }

            DispatchQueue.main.async {
                self.myListings = fetched
            }
        }
    }

    func loadUserData() {
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? ""
        }
    }

    func uploadProfileImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4),
              let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Image upload failed: \(error.localizedDescription)")
                completion(false)
            } else {
                self.profileUIImage = image
                completion(true)
            }
        }
    }

    func logout(completion: @escaping () -> Void) {
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    func updateEmailAndOrPassword(
        newEmail: String?,
        newPassword: String?,
        currentPassword: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                completion("You must be logged in to update your info.")
            }
            return
        }

        guard let currentEmail = user.email else {
            DispatchQueue.main.async {
                completion("Your current email couldn't be verified.")
            }
            return
        }

        guard user.isEmailVerified else {
            user.sendEmailVerification { err in
                if let err = err {
                    print("Failed to send verification email: \(err.localizedDescription)")
                } else {
                    print("Verification email sent to \(currentEmail)")
                }
            }
            DispatchQueue.main.async {
                completion("Please verify your current email before updating. We've sent you a verification link.")
            }
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Reauthentication failed: \(error.localizedDescription)")
                }
                return
            }

            var results: [String] = []
            var errors: [String] = []
            let group = DispatchGroup()

            if let newEmail = newEmail, !newEmail.isEmpty, newEmail != currentEmail {
                group.enter()
                user.updateEmail(to: newEmail) { error in
                    if let error = error as NSError? {
                        var msg = error.localizedDescription
                        if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                            msg = "That email is already in use."
                        } else if error.code == AuthErrorCode.invalidEmail.rawValue {
                            msg = "Invalid email format."
                        }
                        errors.append("Email update failed: \(msg)")
                    } else {
                        self.userEmail = newEmail
                        results.append("Email updated")

                        user.sendEmailVerification { error in
                            if let error = error {
                                print("Verification email to new email failed: \(error.localizedDescription)")
                            } else {
                                print("Verification sent to new email: \(newEmail)")
                            }
                        }
                    }
                    group.leave()
                }
            }

            if let newPassword = newPassword, !newPassword.isEmpty {
                group.enter()
                user.updatePassword(to: newPassword) { error in
                    if let error = error as NSError? {
                        errors.append("Password update failed: \(error.localizedDescription)")
                    } else {
                        results.append("Password updated")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                if !errors.isEmpty {
                    completion(errors.joined(separator: "\n"))
                } else if results.isEmpty {
                    completion("Nothing changed.")
                } else {
                    let msg = results.joined(separator: " & ")
                    completion("\(msg). If you updated your email, a verification link was sent.")
                }
            }
        }
    }
}
