import Foundation
import SwiftUI

// Define a struct for the Posting with identifiable properties
struct Posting: Identifiable, Hashable {
    // Unique identifier for each vehicle part listing
    let id = UUID()
    let phoneNumber: String
    var Description: String
    var Price: String
    var Condition: String
    var TypeOfPart: String
}

struct vendorView: View {
    
    // User input fields for vehicle part details
    @State private var phoneNumber: String = ""
    @State private var Description: String = ""
    @State private var Price: String = ""
    @State private var Condition: String = ""
    @State private var TypeOfPart: String = ""
    @State private var errorMessage: String = "" // Error message that will be displayed if validation fails
    
    // Function to check if all required fields are filled in by the user
    func checking() {
        // Check if any required field is empty
        if phoneNumber.isEmpty || Description.isEmpty || Price.isEmpty || Condition.isEmpty || TypeOfPart.isEmpty {
            errorMessage = "Please fill in all required fields." // Display error message if any field is empty
        } else {
            errorMessage = "" // Clear error message if all fields are filled
            // Proceed with posting submission or any other actions (like saving or sending data)
            print("All fields are filled, ready for submission!") // This is just a placeholder for actual submission logic
            // Optionally, you can clear the form fields after successful submission:
            clearFields()
        }
    }
    
    // Function to clear all fields after submission
    func clearFields() {
        phoneNumber = ""
        Description = ""
        Price = ""
        Condition = ""
        TypeOfPart = ""
    }

    var body: some View {
        // Use NavigationView to allow for navigation (e.g., in a larger app)
        NavigationView {
            BaseView {
                // Use VStack to organize the layout vertically with some spacing
                VStack(spacing: 20) {
                    
                    // Phone Number input field
                    TextField("Phone-Number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded style for the text field
                        .keyboardType(.phonePad) // Use phone keypad for the phone number input
                        .padding(.horizontal)
                    
                    // Description input field
                    TextField("Description", text: $Description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Price input field
                    TextField("Price", text: $Price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad) // Use decimal pad for price input
                        .padding(.horizontal)
                    
                    // Condition input field (e.g., New/Used)
                    TextField("Condition: New/Used", text: $Condition)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Type of Part input field
                    TextField("Type of Part", text: $TypeOfPart)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Show error message if any field is empty
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red) // Make the error message red for visibility
                            .padding(.top, 10)
                    }
                    
                    // Submit Button
                    Button(action: {
                        checking() // Call the checking function when the button is tapped
                    }) {
                        Text("Submit Listing") // Button text
                            .padding()
                            .background(Color.blue) // Blue background color for the button
                            .foregroundColor(.white) // White text color
                            .cornerRadius(8) // Rounded corners for the button
                    }
                    .padding(.top, 20) // Add some space above the button
                }
                .padding() // Add some padding around the VStack
                .background(Color.gray.opacity(0.2)) // Set a light gray background for the form
                .cornerRadius(12) // Rounded corners for the form container
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the view fill the available space
                .background(Color.gray) // Dark grey background for the entire screen
                .edgesIgnoringSafeArea(.all) // Make the background color extend to the edges of the screen
            }
        }
    }
}

struct vendorView_Previews: PreviewProvider {
    static var previews: some View {
        vendorView() // Preview the vendorView
    }
}

