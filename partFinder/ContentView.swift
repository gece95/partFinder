/*
 Welcome to partFinder team
 
 ContentView.swift
 Created by Gerardo Cervantes on 2/4/25
 */
import SwiftUI
import Foundation

// Defines a Vehicle struct that conforms to Identifiable and Hashable
// Used to store vehicle details such as make, model, year, and trim
struct Vehicle: Identifiable, Hashable {
    // Unique identifier for each vehicle
    let id = UUID()
    var make: String
    var model: String
    var year: String
    var trim: String
}

// Main ContentView displaying vehicle selection and available parts
struct ContentView: View {
    // Stores a list of vehicles
    @State private var vehicles: [Vehicle] = []
    // Stores multiple vehicles
    @State private var savedVehicles: [Vehicle] = []
    // Tracks the selected vehicle
    @State private var selectedVehicle: Vehicle? = nil
    // Controls vehicle selection popup
    @State private var showingVehicleSelection: Bool = false
    
    // User input fields for vehicle details
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var trim: String = ""
    @State private var selectedPart: String = "Select a Part"
    @State private var navigate: Bool = false
    
    // modified to only include the engine button for demo purposes FIXME: add more later
    // "Battery", "Oil Filter", "Brake Pads", "Spark Plugs", "Air Filter", "Tires"]
    var relevantParts = ["Engine"]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 100)
                
                VStack {
                    // App title button (acts as a reset)
                    Button(action: {
                        selectedVehicle = nil
                    }) {
                        Text("partFinder")
                            .font(.custom("SnellRoundhand-Bold", size: 55))
                            .foregroundColor(Color.blue.opacity(0.9))
                            .underline()
                    }
                }
                .padding(.bottom, 50)

                // Displays selected vehicle information if available
                if let vehicle = selectedVehicle {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selected Vehicle:")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("\(vehicle.year) \(vehicle.make) \(vehicle.model) \(vehicle.trim)")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    
                    // Moved the "Select Another Vehicle" button here
                    Button(action: {
                        showingVehicleSelection.toggle()
                    }) {
                        Text("Select Another Vehicle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingVehicleSelection) {
                        VehicleSelectionView(savedVehicles: $savedVehicles, selectedVehicle: $selectedVehicle, isPresented: $showingVehicleSelection)
                    }


                    // Display the list of parts directly
                    ScrollView {
                        VStack {
                            Text("Available Parts:")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            // Displays available parts as navigation links
                            ForEach(relevantParts, id: \.self) { part in
                                NavigationLink(destination: PartListingsView(partType: part)) {
                                    Text(part)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue.opacity(0.9))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                } else {
                    // Vehicle input fields for new vehicle entry
                    VStack(spacing: 20) {
                        TextField("Make", text: $make)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("Model", text: $model)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("Year", text: $year)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("Trim", text: $trim)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                    
                    // "Save vehicle" button
                    Button(action: {
                        if !make.isEmpty && !model.isEmpty && !year.isEmpty && !trim.isEmpty {
                            let newVehicle = Vehicle(make: make, model: model, year: year, trim: trim)
                            savedVehicles.append(newVehicle)
                            selectedVehicle = newVehicle
                            make = ""
                            model = ""
                            year = ""
                            trim = ""
                        }
                    }) {
                        Text("Save Vehicle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
}

struct VehicleSelectionView: View {
    @Binding var savedVehicles: [Vehicle]
    @Binding var selectedVehicle: Vehicle?
    @Binding var isPresented: Bool  // Controls closing the view

    // View for selecting a saved vehicle
    var body: some View {
        VStack {
            Text("Select a Vehicle")
                .font(.title2)
                .padding()

            if savedVehicles.isEmpty {
                Text("No saved vehicles. Add a new one.")
                    .padding()
            } else {
                List(savedVehicles, id: \.self) { vehicle in
                    Button(action: {
                        selectedVehicle = vehicle
                        isPresented = false // Dismiss view when a vehicle is selected
                    }) {
                        HStack {
                            Text("\(vehicle.year) \(vehicle.make) \(vehicle.model) \(vehicle.trim)")
                            Spacer()
                        }
                        .padding()
                    }
                }
            }

            // Button to add a new vehicle
            Button(action: {
                selectedVehicle = nil
                isPresented = false // Dismiss view
            }) {
                Text("Add New Vehicle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
