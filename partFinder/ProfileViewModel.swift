import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = true
    @AppStorage("userEmail") var userEmail = ""
    @AppStorage("userName") var userName = ""
    
    @Published var userLocation = "California"
    @Published var profileImageURL = ""
    @Published var profileUIImage: UIImage?
    
    init() {
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? "Unknown"
            fetchProfileImage(for: user.uid)
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: ((URL?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion?(nil)
            return
        }
        
        let ref = Storage.storage().reference().child("profile_pictures/\(uid).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if error == nil {
                ref.downloadURL { url, _ in
                    if let url = url {
                        self.profileImageURL = url.absoluteString
                        self.profileUIImage = image
                        
                        Firestore.firestore().collection("users").document(uid).setData([
                            "profileImageURL": url.absoluteString
                        ], merge: true)
                    }
                    completion?(url)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    private func fetchProfileImage(for uid: String) {
        let ref = Storage.storage().reference().child("profile_pictures/\(uid).jpg")
        ref.downloadURL { url, error in
            if let url = url {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileUIImage = uiImage
                        }
                    }
                }.resume()
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            userEmail = ""
            userName = ""
            completion()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    func updateEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }
        
        user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
            if let error = error {
                completion(error)
            } else {
                DispatchQueue.main.async {
                    self.userEmail = newEmail
                }
                print("Verification email sent to \(newEmail). User must confirm before email is updated.")
                completion(nil)
            }
        }
    }
}
