import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

struct Vehicle: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var make: String
    var model: String
    var trim: String
    var year: String

    init(id: UUID = UUID(), make: String, model: String, trim: String, year: String) {
        self.id = id
        self.make = make
        self.model = model
        self.trim = trim
        self.year = year
    }

    var displayName: String {
        "\(year) \(make) \(model) \(trim)"
    }

    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.make == rhs.make && lhs.model == rhs.model && lhs.trim == rhs.trim && lhs.year == rhs.year
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(make)
        hasher.combine(model)
        hasher.combine(trim)
        hasher.combine(year)
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    
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
<<<<<<< HEAD

    @State private var firebaseListings: [Vehicle] = []

=======
    
    
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
    
>>>>>>> develop
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
<<<<<<< HEAD

    var availableVehicles: [Vehicle] {
        return firebaseListings
    }

    var availableMakes: [String] {
        Set(availableVehicles.map { $0.make }).sorted()
    }

    var availableModels: [String] {
        Set(availableVehicles.filter { $0.make == newVehicle.make }.map { $0.model }).sorted()
    }

    var availableTrims: [String] {
        Set(availableVehicles.filter { $0.make == newVehicle.make && $0.model == newVehicle.model }.map { $0.trim }).sorted()
    }

    var availableYears: [String] {
        Set(availableVehicles.filter { $0.make == newVehicle.make && $0.model == newVehicle.model && $0.trim == newVehicle.trim }.map { $0.year }).sorted()
    }

    func fetchVehicleJSONFromFirebase(completion: @escaping ([Vehicle]) -> Void) {
        let ref = Database.database().reference(withPath: "vehicles")

        ref.observeSingleEvent(of: .value) { snapshot in
            var vehicles: [Vehicle] = []

            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String: Any] else { continue }

                let make = dict["brand"] as? String ?? ""
                let model = dict["model"] as? String ?? ""
                let trim = dict["trim"] as? String ?? ""
                let year = String(describing: dict["year"] ?? "") // Ensure year is always a String

                let vehicle = Vehicle(make: make, model: model, trim: trim, year: year)
                vehicles.append(vehicle)
            }

            print("✅ Successfully loaded \(vehicles.count) vehicles from Realtime DB")
            completion(vehicles)
        }
    }

=======
    
>>>>>>> develop
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
<<<<<<< HEAD
=======
                                    // City dropdown
>>>>>>> develop
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
<<<<<<< HEAD

=======
                                
>>>>>>> develop
                                if let zip = locationManager.zipCode {
                                    Text("ZIP Code: \(zip)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.bottom, 4)
                                }
<<<<<<< HEAD

                                VStack(spacing: 12) {
                                    if !availableYears.isEmpty {
                                        Menu {
                                            ForEach(availableYears, id: \.self) { year in
                                                Button {
                                                    newVehicle.year = year
                                                } label: {
                                                    Text(year)
                                                }
                                            }
                                        } label: {
                                            DropdownLabel(text: newVehicle.year, placeholder: "Year")
                                        }
                                    }

                                    Menu {
                                        ForEach(availableMakes, id: \.self) { make in
                                            Button {
                                                newVehicle.make = make
                                                newVehicle.model = ""
                                                newVehicle.trim = ""
                                                newVehicle.year = ""
                                            } label: {
                                                Text(make)
                                            }
                                        }
                                    } label: {
                                        DropdownLabel(text: newVehicle.make, placeholder: "Make")
                                    }

                                    if !availableModels.isEmpty {
                                        Menu {
                                            ForEach(availableModels, id: \.self) { model in
                                                Button {
                                                    newVehicle.model = model
                                                    newVehicle.trim = ""
                                                    newVehicle.year = ""
                                                } label: {
                                                    Text(model)
                                                }
                                            }
                                        } label: {
                                            DropdownLabel(text: newVehicle.model, placeholder: "Model")
                                        }
                                    }

                                    if !availableTrims.isEmpty {
                                        Menu {
                                            ForEach(availableTrims, id: \.self) { trim in
                                                Button {
                                                    newVehicle.trim = trim
                                                    newVehicle.year = ""
                                                } label: {
                                                    Text(trim)
                                                }
                                            }
                                        } label: {
                                            DropdownLabel(text: newVehicle.trim, placeholder: "Trim")
                                        }
                                    }

                                    Button("Add Vehicle") {
                                        guard !newVehicle.make.isEmpty,
                                              !newVehicle.model.isEmpty,
                                              !newVehicle.trim.isEmpty,
                                              !newVehicle.year.isEmpty else { return }

                                        vehicles.append(newVehicle)
                                        selectedVehicle = newVehicle
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
=======
                                
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
>>>>>>> develop
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
        }
<<<<<<< HEAD
        .onAppear {
            fetchVehicleJSONFromFirebase { vehiclesFromDB in
                firebaseListings = vehiclesFromDB
            }
        }
    }
}

struct DropdownLabel: View {
    let text: String
    let placeholder: String

    var body: some View {
        HStack {
            Text(text.isEmpty ? placeholder : text)
                .foregroundColor(text.isEmpty ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
=======
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
                   let year = value["year"] as? String {
                    
                    let vehicle = Vehicle(make: make, model: model, trim: trim, year: year)
                    loadedVehicles.append(vehicle)
                }
            }

            vehicles = loadedVehicles
            print("✅ Loaded \(vehicles.count) vehicles from Firebase.")
>>>>>>> develop
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    }

<<<<<<< HEAD
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
=======
    
    
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
/*
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
>>>>>>> develop
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}
 */

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HomeViewModel())
            .environmentObject(LocationManager())
            .previewDevice("iPhone 12")
    }
}
