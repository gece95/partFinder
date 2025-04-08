//
//  UserManager.swift
//  partFinder
//
//  Created by Gerardo Cervantes on 4/7/25.
//


import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserManager {
    private let auth = Auth.auth()
    private let db = Database.database().reference()

    func registerUser(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let userID = result?.user.uid else {
                completion(.failure(NSError(domain: "NoUserID", code: -1)))
                return
            }

            let userProfile: [String: Any] = [
                "uid": userID,
                "email": email,
                "name": name,
                "createdAt": Date().timeIntervalSince1970
            ]

            self?.db.child("users").child(userID).setValue(userProfile) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(name, forKey: "userName")
                        UserDefaults.standard.set(email, forKey: "userEmail")
                    }
                    completion(.success(()))
                }
            }
        }
    }
}
