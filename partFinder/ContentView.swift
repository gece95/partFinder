import SwiftUI
import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase



struct Vehicle: Identifiable, Equatable {
    var id = UUID()
    var make: String
    var model: String
    var trim: String
    var year: String

    var displayName: String {
        "\(year) \(make) \(model) \(trim)"
    }
}


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showEditVehicleSheet = false
    @State private var vehicleToEdit: Vehicle? = nil

    
    @AppStorage("userUID") var userUID = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""
    
    @State private var newVehicle = Vehicle(make: "", model: "", trim: "", year: "")
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?
    
    @State private var selectedCategoryListings: [Listing] = []
    @State private var showListings = false
    @State private var selectedCategoryLabel: String = ""
    
    
    let years = Array(1980...2025).map { String($0) }
    let makes = ["Ford", "Chevrolet", "Toyota", "Honda"]
    let modelsByMake = [
        "Ford": ["F-150", "Mustang", "Explorer"],
        "Chevrolet": ["Silverado", "Malibu", "Equinox"],
        "Toyota": ["Camry", "Corolla", "RAV4"],
        "Honda": ["Civic", "Accord", "CR-V"]
    ]
    let trimsByModel = [
        "Camry": ["LE", "SE", "XLE"],
        "Corolla": ["L", "LE", "XSE"],
        "RAV4": ["LE", "XLE", "Limited"],
        "Civic": ["LX", "Sport", "EX"],
        "Accord": ["LX", "Sport", "EX-L"],
        "CR-V": ["LX", "EX", "Touring"],
        "F-150": ["XL", "XLT", "Lariat"],
        "Mustang": ["EcoBoost", "GT", "Mach 1"],
        "Explorer": ["Base", "XLT", "Limited"],
        "Silverado": ["Work Truck", "LT", "High Country"],
        "Malibu": ["LS", "RS", "Premier"],
        "Equinox": ["L", "LS", "LT"]
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        BaseView {
            ZStack {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 0) {
                            ScrollView {
                                HStack {
                                    // City dropdown
                                    Menu {
                                        ForEach(viewModel.cities, id: \.self) { city in
                                            Button(city) {
                                                locationManager.requestLocation()
                                                viewModel.selectedCity = city
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "line.3.horizontal.decrease.circle")
                                                .font(.title2)
                                                .foregroundColor(.gray)
                                            Text(viewModel.selectedCity)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("partFinder")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                
                                if let zip = locationManager.zipCode {
                                    Text("ZIP Code: \(zip)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.bottom, 4)
                                }
                                
                                VStack(spacing: 12) {
                                    // Year Picker
                                    Menu {
                                        ForEach(years, id: \.self) { year in
                                            Button(action: {
                                                newVehicle.year = year
                                            }) {
                                                Text(year)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(newVehicle.year.isEmpty ? "Year" : newVehicle.year)
                                                .foregroundColor(newVehicle.year.isEmpty ? .gray : .primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Make Picker
                                    Menu {
                                        ForEach(makes, id: \.self) { make in
                                            Button(action: {
                                                newVehicle.make = make
                                                newVehicle.model = ""
                                                newVehicle.trim = ""
                                            }) {
                                                Text(make)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(newVehicle.make.isEmpty ? "Make" : newVehicle.make)
                                                .foregroundColor(newVehicle.make.isEmpty ? .gray : .primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    
                                    // Model Picker
                                    if let models = modelsByMake[newVehicle.make] {
                                        Menu {
                                            ForEach(models, id: \.self) { model in
                                                Button(action: {
                                                    newVehicle.model = model
                                                    newVehicle.trim = ""
                                                }) {
                                                    Text(model)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(newVehicle.model.isEmpty ? "Model" : newVehicle.model)
                                                    .foregroundColor(newVehicle.model.isEmpty ? .gray : .primary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    // Trim Picker
                                    if let trims = trimsByModel[newVehicle.model] {
                                        Menu {
                                            ForEach(trims, id: \.self) { trim in
                                                Button(action: {
                                                    newVehicle.trim = trim
                                                }) {
                                                    Text(trim)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(newVehicle.trim.isEmpty ? "Trim" : newVehicle.trim)
                                                    .foregroundColor(newVehicle.trim.isEmpty ? .gray : .primary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    
                                    Button("Add Vehicle") {
                                        guard !newVehicle.make.isEmpty,
                                              !newVehicle.model.isEmpty,
                                                  !newVehicle.year.isEmpty else { return }
                                                  
                                                  vehicles.append(newVehicle)
                                                  selectedVehicle = newVehicle
                                                  saveVehicleToFirebase(newVehicle)
                                                  newVehicle = Vehicle(make: "", model: "", trim: "", year: "")
                                              }
                                              .frame(maxWidth: .infinity)
                                              .padding()
                                              .background(Color.blue)
                                              .foregroundColor(.white)
                                              .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                if !vehicles.isEmpty {
                                    Menu {
                                        ForEach(vehicles) { vehicle in
                                            Button(vehicle.displayName) {
                                                selectedVehicle = vehicle
                                            }
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray6))
                                            HStack {
                                                Text(selectedVehicle?.displayName ?? "Select Vehicle")
                                                    .foregroundColor(.primary)
                                                    .padding(.leading)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing)
                                            }
                                        }
                                        .frame(height: 45)
                                        .padding(.horizontal)
                                    }
                                }

                                if let selected = selectedVehicle {
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            vehicleToEdit = selected
                                            showEditVehicleSheet = true
                                        }) {
                                            Label("Edit Vehicle", systemImage: "pencil")
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.blue)

                                        Button(action: {
                                            deleteVehicleFromFirebase(vehicle: selected)
                                            selectedVehicle = nil
                                        }) {
                                            Label("Delete Vehicle", systemImage: "trash")
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.red)
                                    }
                                    .padding(.horizontal)
                                }
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Categories")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("Show All")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal)
                                        
                                        LazyVGrid(columns: columns, spacing: 20) {
                                            ForEach(viewModel.categories) { category in
                                                Button(action: {
                                                    if category.label == "Engine" {
                                                        selectedCategoryLabel = category.label
                                                        selectedCategoryListings = dummyListings.filter { $0.partType == category.label }
                                                        showListings = true
                                                    }
                                                }) {
                                                    CategoryItem(icon: category.icon, label: category.label)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    Spacer().frame(height: geometry.safeAreaInsets.bottom)
                                }.onAppear {
                                    loadVehiclesFromFirebase()
                                }
                            }
                        }
                    }
                }
            }
        .sheet(isPresented: $showEditVehicleSheet) {
            if let vehicle = vehicleToEdit {
                EditVehicleView(vehicle: vehicle,
                                onSave: { updated in
                                    updateVehicleInFirebase(vehicle: updated)
                                },
                                onDelete: {
                                    deleteVehicleFromFirebase(vehicle: vehicle)
                                })
            }
        }

        }
    func saveVehicleToFirebase(_ vehicle: Vehicle) {
        guard !userUID.isEmpty else {
            print("❌ User UID is empty. Cannot save vehicle.")
            return
        }
        let ref = Database.database().reference()
        let vehicleData = [
            "make": vehicle.make,
            "model": vehicle.model,
            "trim": vehicle.trim,
            "year": vehicle.year
        ]
        let path = "users/\(userUID)/vehicles/\(vehicle.id.uuidString)"
            print("📍 Saving vehicle to: \(path)")
            print("📦 Vehicle data: \(vehicleData)")

            ref.child("users")
                .child(userUID)
                .child("vehicles")
                .child(vehicle.id.uuidString)
                .setValue(vehicleData) { error, _ in
                    if let error = error {
                        print("❌ Failed to save vehicle: \(error.localizedDescription)")
                    } else {
                        print("✅ Vehicle saved to Firebase")
                    }
                }
        }
    func loadVehiclesFromFirebase() {
        guard !userUID.isEmpty else {
            print("❌ User UID is empty. Cannot load vehicles.")
            return
        }

        let ref = Database.database().reference()
        ref.child("users").child(userUID).child("vehicles").observeSingleEvent(of: .value) { snapshot in
            var loadedVehicles: [Vehicle] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let value = snap.value as? [String: Any],
                   let make = value["make"] as? String,
                   let model = value["model"] as? String,
                   let trim = value["trim"] as? String,
                   let year = value["year"] as? String,
                   let id = UUID(uuidString: snap.key) {
                    
                    let vehicle = Vehicle(id: id, make: make, model: model, trim: trim, year: year)
                    loadedVehicles.append(vehicle)
                }
            }

            vehicles = loadedVehicles
            print("✅ Loaded \(vehicles.count) vehicles from Firebase.")
        }
    }
    
    
    func deleteVehicleFromFirebase(_ vehicleID: String) {
        guard !userUID.isEmpty else { return }
        let ref = Database.database().reference()
        ref.child("users").child(userUID).child("vehicles").child(vehicleID).removeValue { error, _ in
            if let error = error {
                print("❌ Error deleting: \(error.localizedDescription)")
            } else {
                print("✅ Vehicle deleted")
                loadVehiclesFromFirebase() // Refresh UI
            }
        }
    }

    
    func updateVehicleInFirebase(vehicleID: String, updatedVehicle: Vehicle) {
        guard !userUID.isEmpty else { return }
        let ref = Database.database().reference()
        let vehicleData = [
            "make": updatedVehicle.make,
            "model": updatedVehicle.model,
            "trim": updatedVehicle.trim,
            "year": updatedVehicle.year
        ]
        ref.child("users").child(userUID).child("vehicles").child(vehicleID).updateChildValues(vehicleData) { error, _ in
            if let error = error {
                print("❌ Error updating: \(error.localizedDescription)")
            } else {
                print("✅ Vehicle updated")
                loadVehiclesFromFirebase()
            }
        }
    }

    func updateVehicleInFirebase(vehicle: Vehicle) {
        guard !userUID.isEmpty else { return }
        let ref = Database.database().reference()
        let vehicleData = [
            "make": vehicle.make,
            "model": vehicle.model,
            "trim": vehicle.trim,
            "year": vehicle.year
        ]
        ref.child("users").child(userUID).child("vehicles").child(vehicle.id.uuidString).setValue(vehicleData)
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
        }
    }

    func deleteVehicleFromFirebase(vehicle: Vehicle) {
        guard !userUID.isEmpty else { return }
        let ref = Database.database().reference()
        ref.child("users").child(userUID).child("vehicles").child(vehicle.id.uuidString).removeValue()
        vehicles.removeAll { $0.id == vehicle.id }
    }

    
    
    }

    

    
    
        struct CategoryItem: View {
            let icon: String
            let label: String
            
            var body: some View {
                VStack(spacing: 8) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)
            }
        }

struct ProfileView: View {
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false

    var body: some View {
        BaseView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    Text("\(userEmail)")
                        .foregroundColor(.white)
                    
                    Button("Logout") {
                        try? Auth.auth().signOut()
                        isLoggedIn = false
                        userName = ""
                        userEmail = ""
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    Spacer()
                }
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
