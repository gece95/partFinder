/*
 Welcome to partFinder team
 
 ContentView.swift
 Created by Gerardo Cervantes on 2/4/25
 */
import SwiftUI
import Foundation

struct Vehicle: Identifiable, Hashable {
    let id = UUID()
    var make: String
    var model: String
    var year: String
    var trim: String
}

class Listing: Identifiable {
    let id = UUID()
    var title: String
    var partType: String
    var make: String
    var model: String
    var year: String
    var trim: String
    var price: Double
    var description: String
    var city: String
    var phoneNumber: String
    
    init(title: String, partType: String, make: String, model: String, year: String, trim: String, price: Double, description: String, city: String, phoneNumber: String) {
        self.title = title
        self.partType = partType
        self.make = make
        self.model = model
        self.year = year
        self.trim = trim
        self.price = price
        self.description = description
        self.city = city
        self.phoneNumber = phoneNumber
    }
}

let dummyListings: [Listing] = [
    Listing(title: "V8 Engine", partType: "Engine", make: "Ford", model: "Mustang", year: "2019", trim: "GT", price: 3500.0, description: "High-performance V8 engine in excellent condition.", city: "Los Angeles", phoneNumber: "123-456-7890"),
    Listing(title: "Turbocharged Engine", partType: "Engine", make: "Subaru", model: "WRX", year: "2020", trim: "STI", price: 4200.0, description: "Low-mileage turbocharged engine, perfect for performance builds.", city: "Denver", phoneNumber: "987-654-3210"),
    Listing(title: "Hybrid Engine", partType: "Engine", make: "Toyota", model: "Prius", year: "2021", trim: "LE", price: 2800.0, description: "Eco-friendly hybrid engine, great for fuel efficiency.", city: "San Francisco", phoneNumber: "555-123-4567"),
    Listing(title: "Supercharged V6", partType: "Engine", make: "Jaguar", model: "F-Type", year: "2018", trim: "R-Dynamic", price: 5000.0, description: "Powerful supercharged V6 engine, ready for installation.", city: "Chicago", phoneNumber: "111-222-3333"),
    Listing(title: "V8 Engine", partType: "Engine", make: "Ford", model: "Mustang", year: "2019", trim: "GT", price: 3500.0, description: "High-performance V8 engine in excellent condition.", city: "Los Angeles", phoneNumber: "123-456-7890"),
    Listing(title: "Turbocharged Engine", partType: "Engine", make: "Subaru", model: "WRX", year: "2020", trim: "STI", price: 4200.0, description: "Low-mileage turbocharged engine, perfect for performance builds.", city: "Denver", phoneNumber: "987-654-3210"),
    Listing(title: "Hybrid Engine", partType: "Engine", make: "Toyota", model: "Prius", year: "2021", trim: "LE", price: 2800.0, description: "Eco-friendly hybrid engine, great for fuel efficiency.", city: "San Francisco", phoneNumber: "555-123-4567"),
    Listing(title: "Supercharged V6", partType: "Engine", make: "Jaguar", model: "F-Type", year: "2018", trim: "R-Dynamic", price: 5000.0, description: "Powerful supercharged V6 engine, ready for installation.", city: "Chicago", phoneNumber: "111-222-3333")
]

struct ContentView: View {
    @State private var vehicles: [Vehicle] = []
    @State private var savedVehicles: [Vehicle] = []  // Stores multiple vehicles
    @State private var selectedVehicle: Vehicle? = nil
    @State private var showingVehicleSelection: Bool = false  // Controls vehicle selection popup
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var trim: String = ""
    @State private var selectedPart: String = "Select a Part"
    @State private var navigate: Bool = false
    
    // modified to only include the engine button for demo purposes 
    var relevantParts = ["Engine"] //, "Battery", "Oil Filter", "Brake Pads", "Spark Plugs", "Air Filter", "Tires"]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 100)
                
                VStack {
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


struct PartListingsView: View {
    var partType: String
    @State private var priceFilter: Double = 5000.0
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Available \(partType) Listings:")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                VStack {
                    Text("\nFilter by Maximum Price: $\(priceFilter, specifier: "%.2f")")
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    
                    Slider(value: $priceFilter, in: 0...5000, step: 50)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                
                LazyVStack(spacing: 15) {
                    ForEach(dummyListings.filter { $0.partType == partType && $0.price <= priceFilter }, id: \.id) { listing in
                        VStack(alignment: .leading) {
                            Text("\(listing.title) - $\(listing.price, specifier: "%.2f")")
                                .font(.headline)
                                .bold()
                                .padding(.bottom, 5)
                                .foregroundColor(Color.white)
                            
                            Text("Make: \(listing.make), Model: \(listing.model), Year: \(listing.year), Trim: \(listing.trim)")
                                .padding(.bottom, 5)
                                .foregroundColor(Color.white)
                            
                            Text("City: \(listing.city)")
                                .padding(.bottom, 5)
                                .foregroundColor(Color.white)
                            
                            Text("Contact: \(listing.phoneNumber)")
                                .padding(.bottom, 5)
                                .foregroundColor(Color.white)
                            
                            Text("Description: \(listing.description)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 10)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
