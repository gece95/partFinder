import SwiftUI
import FirebaseAuth
import FirebaseFirestore
struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""
    @AppStorage("userUID") var userUID = ""  // ⬅️ Store UID for Firebase paths

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var message = ""
    @State private var isLoginMode = true
    @State private var showResetPassword = false
    @State private var isSuccessMessage = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(isLoginMode ? "Login" : "Create Account")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                if !isLoginMode {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.white)
                        .cornerRadius(5)
                        .padding(.horizontal)
                }
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                
                if isLoginMode {
                    Button("Forgot Password?") {
                        showResetPassword = true
                    }
                    .foregroundColor(.blue)
                }
                
                Button(isLoginMode ? "Login" : "Create Account") {
                    if isLoginMode {
                        loginUser()
                    } else {
                        registerUser()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button(isLoginMode ? "Don\'t have an account? Sign Up" : "Already have an account? Login") {
                    isLoginMode.toggle()
                    message = ""
                }
                .foregroundColor(.gray)
                
                Text(message)
                    .foregroundColor(isSuccessMessage ? .green : .red)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.top)
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView()
            }
        }
    }
    /*
    func registerUser() {
        UserManager().registerUser(email: email, password: password, name: name) { result in
            switch result {
            case .success:
                if let currentUser = Auth.auth().currentUser {
                    userUID = currentUser.uid  // Save UID for future DB access
                    userName = name
                    userEmail = email
                    isLoggedIn = true
                    message = "Account created!"
                    isSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            case .failure(let error):
                message = "\(error.localizedDescription)"
                isSuccessMessage = false
            }
        }
    }
    */
    
    func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                return
            }
            
            guard let user = result?.user else {
                message = "User registration failed."
                return
            }
            
            // Update display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in }
            
            // Save to AppStorage
            userName = name
            userEmail = email
            isLoggedIn = true

            // Save to Firestore
            saveUserToFirestore(uid: user.uid, name: name, email: email)

            message = "Account created!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }

    func saveUserToFirestore(uid: String, name: String, email: String, profileImageURL: String? = nil) {
        var userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        if let url = profileImageURL {
            userData["profileImageURL"] = url
        }

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
            } else {
                print("User successfully saved to Firestore.")
            }
        }
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = "\(error.localizedDescription)"
                isSuccessMessage = false
            } else if let user = result?.user {
                userEmail = email
                userName = user.displayName ?? ""
                userUID = user.uid  // Save UID for future DB access
            } else {
                print("Firebase signIn success — waiting for currentUser to be set...")
                waitForUser(retries: 10)
            }
        }
    }
    
    func waitForUser(retries: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let user = Auth.auth().currentUser {
                print("currentUser available: \(user.email ?? "no email")")
                userEmail = user.email ?? ""
                userName = user.displayName ?? ""

                isLoggedIn = true
                isSuccessMessage = true
                dismiss()
            } else if retries > 0 {
                print("Waiting for currentUser... \(retries) tries left")
                waitForUser(retries: retries - 1)
            } else {
                print("currentUser never became available")
                message = "Login failed: user not found"
            }
        }
    }
    
}
