import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PaymentCard: Identifiable {
    var id: String
    var cardholderName: String
    var cardLast4: String
    var expiryDate: String
    var billingAddress: [String: String]
}

struct PaymentMethodsView: View {
    @AppStorage("userUID") var userUID: String = ""

    @State private var cardholderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""

    @State private var saveMessage: String?
    @State private var savedCards: [PaymentCard] = []
    @State private var isAddingCard = false

    var body: some View {
        NavigationView{
            BaseView{
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Payment Methods")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            if !savedCards.isEmpty {
                                ForEach(savedCards) { card in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Cardholder: \(card.cardholderName)")
                                        Text("Card ending in •••• \(card.cardLast4)")
                                        Text("Expires: \(card.expiryDate)")
                                        Button("Remove Card") {
                                            removeCard(id: card.id)
                                        }
                                        .foregroundColor(.red)
                                    }
                                    .padding()
                                    .background(Color(.darkGray))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                }
                            } else {
                                Text("No saved cards.")
                                    .foregroundColor(.gray)
                            }
                            
                            if isAddingCard {
                                Group {
                                    TextField("Name on Card", text: $cardholderName)
                                    TextField("Card Number", text: $cardNumber)
                                    TextField("Expiry Date (MM/YY)", text: $expiryDate)
                                    SecureField("CVV", text: $cvv)
                                    TextField("Street Address", text: $address)
                                    TextField("City", text: $city)
                                    TextField("State", text: $state)
                                    TextField("Zip Code", text: $zip)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                
                                Button(action: savePaymentMethod) {
                                    Text("Save Card")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            
                            Button(isAddingCard ? "Cancel" : "Add New Card") {
                                isAddingCard.toggle()
                            }
                            .foregroundColor(.blue)
                            
                            if let message = saveMessage {
                                Text(message)
                                    .foregroundColor(.green)
                                    .padding(.top)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear(perform: loadSavedCards)
    }

    func savePaymentMethod() {
        guard !userUID.isEmpty else {
            saveMessage = "User not logged in."
            return
        }

        let cardID = UUID().uuidString
        let maskedCardNumber = String(cardNumber.suffix(4))

        let paymentData: [String: Any] = [
            "cardholderName": cardholderName,
            "cardLast4": maskedCardNumber,
            "expiryDate": expiryDate,
            "billingAddress": [
                "address": address,
                "city": city,
                "state": state,
                "zip": zip
            ],
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore()
            .collection("users")
            .document(userUID)
            .collection("paymentMethod")
            .document(cardID)
            .setData(paymentData) { error in
                if let error = error {
                    saveMessage = "Failed to save: \(error.localizedDescription)"
                } else {
                    saveMessage = "Card saved!"
                    clearForm()
                    isAddingCard = false
                    loadSavedCards()
                }
            }
    }

        func loadSavedCards() {
            guard !userUID.isEmpty else { return }
            
            Firestore.firestore()
                .collection("users")
                .document(userUID)
                .collection("paymentMethod")
                .getDocuments { snapshot, error in
                    if let documents = snapshot?.documents {
                        savedCards = documents.compactMap { doc in
                            let data = doc.data()
                            return PaymentCard(
                                id: doc.documentID,
                                cardholderName: data["cardholderName"] as? String ?? "",
                                cardLast4: data["cardLast4"] as? String ?? "",
                                expiryDate: data["expiryDate"] as? String ?? "",
                                billingAddress: data["billingAddress"] as? [String: String] ?? [:]
                            )
                        }
                    }
        }
    }

    func removeCard(id: String) {
        guard !userUID.isEmpty else { return }

        Firestore.firestore()
            .collection("users")
            .document(userUID)
            .collection("paymentMethod")
            .document(id)
            .delete { error in
                if let error = error {
                    saveMessage = "Failed to remove card: \(error.localizedDescription)"
                } else {
                    saveMessage = "Card removed."
                    loadSavedCards()
                }
            }
    }

    func clearForm() {
        cardholderName = ""
        cardNumber = ""
        expiryDate = ""
        cvv = ""
        address = ""
        city = ""
        state = ""
        zip = ""
    }
}
