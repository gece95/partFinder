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
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
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

// MARK: - ContentView
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
    @State private var firebaseListings: [Vehicle] = []

   
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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

    var body: some View {
        BaseView {
            ScrollView {
                VStack(spacing: 16) {
                    vehicleDropdownSection
                    if !vehicles.isEmpty { savedVehicleSection }
                    categoryGridSection
                }
                .padding()
            }
            .background((colorScheme == .dark ? Color("DarkBackground") : Color.black).ignoresSafeArea())
        }
        .onAppear {
            fetchVehicleJSONFromFirebase { vehiclesFromDB in
                firebaseListings = vehiclesFromDB
            }
            loadVehiclesFromFirebase()
        }
    }

    var vehicleDropdownSection: some View {
        VStack(spacing: 12) {
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
            Button("Add Vehicle") {
                guard !newVehicle.make.isEmpty,
                      !newVehicle.model.isEmpty,
                      !newVehicle.trim.isEmpty,
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
    }


    var savedVehicleSection: some View {
        VStack(spacing: 12) {
            Menu {
                ForEach(vehicles) { vehicle in
                    Button(vehicle.displayName) {
                        selectedVehicle = vehicle
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))
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
            }
        }
    }

    var categoryGridSection: some View {
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

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(destination: ListingView(partType: category.label)) {
                        CategoryItem(icon: category.icon, label: category.label)
                    }
                }
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
        ref.child("users").child(userUID).child("vehicles").child(vehicle.id.uuidString).setValue(vehicleData) { error, _ in
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
        }
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
                let year = String(describing: dict["year"] ?? "")
                let vehicle = Vehicle(make: make, model: model, trim: trim, year: year)
                vehicles.append(vehicle)
            }
            print("Successfully loaded \(vehicles.count) vehicles from Realtime DB")
            completion(vehicles)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
