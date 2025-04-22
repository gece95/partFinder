//
//  PaymentMethodsView.swift
//  partFinder
//
//  Created by Emily marrufo on 4/21/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Payment Method")
                        .font(.title2)
                        .foregroundColor(.white)
                    
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
                        Text("Save Payment Method")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

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

    func savePaymentMethod() {
        guard !userUID.isEmpty else {
            saveMessage = "User not logged in."
            return
        }

        let paymentData: [String: Any] = [
            "cardholderName": cardholderName,
            "cardNumber": cardNumber,
            "expiryDate": expiryDate,
            "cvv": cvv,
            "address": address,
            "city": city,
            "state": state,
            "zip": zip,
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore()
            .collection("users")
            .document(userUID)
            .collection("paymentMethod")
            .document("primary")
            .setData(paymentData) { error in
                if let error = error {
                    saveMessage = "Failed to save: \(error.localizedDescription)"
                } else {
                    saveMessage = "Payment method saved!"
                }
            }
    }
}
