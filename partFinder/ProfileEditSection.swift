import SwiftUI

struct ProfileEditSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var currentPassword: String = ""
    @State private var saveMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Update Account Info")
                    .foregroundColor(.white)
                    .font(.title3)
                    .padding(.bottom)

                // Current password (required)
                SecureField("Enter current password", text: $currentPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                // Optional email update
                TextField("Enter new email (optional)", text: $newEmail)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                // Optional password update
                SecureField("Enter new password (optional)", text: $newPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                // Save button
                Button(action: {
                    viewModel.updateEmailAndOrPassword(
                        newEmail: newEmail.isEmpty ? nil : newEmail,
                        newPassword: newPassword.isEmpty ? nil : newPassword,
                        currentPassword: currentPassword
                    ) { message in
                        DispatchQueue.main.async {
                            saveMessage = message
                        }
                    }
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                // Feedback message
                if let message = saveMessage {
                    Text(message)
                        .foregroundColor(message.contains("failed") ? .red : .green)
                        .font(.footnote)
                }
            }
            .padding()
        }
    }
}

