/*
 Welcome to partFinder team
 
 ContentView.swift
 Created by Gerardo Cervantes on 2/4/25
 */
import SwiftUI

struct Vehicle: Identifiable, Hashable {
    let id = UUID()
    var make: String
    var model: String
    var year: String
    var color: String
}

struct ContentView: View {
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle? = nil
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var color: String = ""
    @State private var showPartsDropdown: Bool = false
    
    // list of relavantParts shown later with showRelavantParts
    var relevantParts = ["Battery", "Oil Filter", "Brake Pads", "Spark Plugs", "Air Filter", "Tires", "FIXME: add more options?"]

    var body: some View {
        NavigationView {
            VStack {
                // ensures font begins under "dynamic island"
                Spacer().frame(height: 100)
                
                // title with centered dash & navigation to home
                VStack {
                    Button(action: {
                        // reset selection to show vehicle list
                        selectedVehicle = nil
                    }) {
                        Text("partFinder")
                            // font style: cursive
                            .font(.custom("SnellRoundhand-Bold", size: 45))
                            // font color
                            .foregroundColor(Color.blue.opacity(500))
                            .underline()
                    }
                }
                .padding(.bottom, 110)

                if let vehicle = selectedVehicle {
                    // display selected vehicle info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selected Vehicle:")
                            .font(.title2)
                            .foregroundColor(.white)
                        //FIXME: keep as one line or seperate?
                        
                        Text("\(vehicle.year) \(vehicle.make) \(vehicle.model) \(vehicle.color)")
                        /*
                        Text("Make: \(vehicle.make)")
                        Text("Model: \(vehicle.model)")
                        Text("Year: \(vehicle.year)")
                        Text("Color: \(vehicle.color)")
                         */
                    }
                    
                    .foregroundColor(.blue)
                    .padding()

                    // dropdown for relevant parts
                    VStack {
                        Button(action: {
                            showPartsDropdown.toggle()
                        }) {
                            Text("Show Relevant Parts")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.9))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }

                        if showPartsDropdown {
                            VStack {
                                ForEach(relevantParts, id: \.self) { part in
                                    Text(part)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(5)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // option to go back and select another vehicle
                    Button(action: {
                        selectedVehicle = nil
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
                    Button(action: {
                    // option to remove a vehicle FIXME: need to add functionality
                    }) {
                        Text("Remove Vehicle")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                } else {
                    if !vehicles.isEmpty {
                        // show list of stored vehicles for selection and give option to add new vehicle
                        Text("Select a Vehicle or Add a New One:")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        ForEach(vehicles, id: \.self) { vehicle in
                            Button(action: {
                                selectedVehicle = vehicle
                            }) {
                                Text(vehicle.model)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                        // allows users to add multiple vehicles
                        // FIXME: store vehicle information once profiles can be set
                        Text("Or Add a New Vehicle:")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }

                    // Vehicle Info Inputs
                    VStack(spacing: 20) {
                        TextField("Make", text: $make)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        TextField("Model", text: $model)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        TextField("Year", text:$year)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        TextField("Color", text: $color)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 10)

                    // Save Vehicle Button
                    Button(action: {
                        if !make.isEmpty && !model.isEmpty && !year.isEmpty && !color.isEmpty {
                            let newVehicle = Vehicle(make: make, model: model, year: year, color: color)
                            vehicles.append(newVehicle) // Save new vehicle
                            selectedVehicle = newVehicle // Select the newly added vehicle
                            make = ""
                            model = ""
                            year = ""
                            color = ""
                        }
                    }) {
                        // allow user to save vehicle information
                        Text("Save Vehicle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // black background
            .background(Color.black)
            // extends background to full screen
            .ignoresSafeArea()
        }
    }
}
// allows us to view app demo via iphone or ipad in content view
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

