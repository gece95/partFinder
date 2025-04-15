import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var message = ""
    @State private var isLoginMode = true
    @State private var showResetPassword = false

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
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.top)
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView()
            }
        }
    }

    func registerUser() {
        UserManager().registerUser(email: email, password: password, name: name) { result in
            switch result {
            case .success:
                userName = name
                userEmail = email
                isLoggedIn = true
                message = "Account created!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            case .failure(let error):
                message = "\(error.localizedDescription)"
            }
        }
    }

    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = "\(error.localizedDescription)"
            } else {
                userEmail = email
                userName = result?.user.displayName ?? ""
                isLoggedIn = true
                dismiss()
            }
        }
    }
}
