import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.title)
                    .bold()

                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Send Reset Link") {
                    Auth.auth().sendPasswordReset(withEmail: email) { error in
                        if let error = error {
                            message = "❌ \(error.localizedDescription)"
                        } else {
                            message = "✅ Reset email sent!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
        }
    }
}
