import SwiftUI

struct ProfileEditSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var currentPassword: String = ""
    @State private var saveMessage: String?

    var body: some View {
        BaseView{
            ZStack {
                GeometryReader { geometry in
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 20) {
                    Text("Update Account Info")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.bottom)
                        .fontWeight(.bold)
                    
                    SecureField("Enter current password", text: $currentPassword)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    TextField("Enter new email (optional)", text: $newEmail)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    SecureField("Enter new password (optional)", text: $newPassword)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
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
                            .fontWeight(.bold)
                    }
                    
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
}

