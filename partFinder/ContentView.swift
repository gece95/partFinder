/*
 temporarily removed year functionality to be able to pull from firebase json file
 will be trying to add years into the file then reimpliment
 */
import SwiftUI
import Foundation
import PhotosUI
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


struct Vehicle: Identifiable, Equatable {
    var id = UUID()
    var make: String
    var model: String
    var trim: String
    //var year: String

    var displayName: String {
        "\(make) \(model) \(trim)"
    }
}
enum VehicleAlert: Identifiable {
    case added, deleted

    var id: String {
        switch self {
        case .added: return "added"
        case .deleted: return "deleted"
        }
    }

    var message: String {
        switch self {
        case .added: return "Vehicle Added"
        case .deleted: return "Vehicle Deleted"
        }
    }
}
struct partCategory: Hashable {
    let icon: String
    let label: String
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var cartManager: CartManager
    
    @AppStorage("userUID") var userUID = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""
    
    @State private var newVehicle = Vehicle(make: "", model: "", trim: "")
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?
    
    @State private var makes: [String] = []
    @State private var modelsByMake: [String: [String]] = [:]
    @State private var trimsByModel: [String: [String]] = [:]
    
    @State private var selectedCategoryListings: [Posting] = []
    @State private var showListings = false
    @State private var selectedCategoryLabel: String = ""
    @State private var noListingsFound = false

    
    enum PriceSortOption: String, CaseIterable {
        case none = "None"
        case lowToHigh = "Price: Low to High"
        case highToLow = "Price: High to Low"
    }

    @State private var selectedSortOption: PriceSortOption = .none
    
    enum ConditionFilterOption: String, CaseIterable {
        case all = "All"
        case new = "New"
        case used = "Used"
    }

    @State private var selectedCondition: ConditionFilterOption = .all
    
    let categories = [
        Category(icon: "engine_icon", label: "Engines"),
        Category(icon: "battery_icon", label: "Batteries"),
        Category(icon: "brake_icon", label: "Brakes"),
        Category(icon: "fluids_icon", label: "Fluids"),
        Category(icon: "turbo_icon", label: "Turbocharger"),
        Category(icon: "gasket_icon", label: "Gaskets")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            BaseView {
                ZStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottom) {
                            (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack(spacing: 0) {
                                ScrollView {
                                    HStack {
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
                                            .frame(maxWidth: .infinity, alignment: .trailing)
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
                                        // yearPicker
                                        makePicker
                                        modelPicker
                                        trimPicker
                                        
                                        Button("Add Vehicle") {
                                            guard !newVehicle.make.isEmpty,
                                                  !newVehicle.model.isEmpty else { return }
                                            
                                            vehicles.append(newVehicle)
                                            selectedVehicle = newVehicle
                                            saveVehicleToFirebase(newVehicle)
                                            newVehicle = Vehicle(make: "", model: "", trim: "")
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
                                            Button("Select Vehicle") {
                                                selectedVehicle = nil
                                            }
                                            
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
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                deleteVehicleFromFirebase(vehicle: selected)
                                                selectedVehicle = nil
                                            }) {
                                                Label("Delete Vehicle", systemImage: "trash")
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.red)
                                            Spacer()
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
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(categories, id: \.label) { category in
                                            Button(action: {
                                                loadListings(for: category.label)
                                            }) {
                                                CategoryItem(icon: category.icon, label: category.label)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    if showListings {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Listings for \(selectedCategoryLabel)")
                                                .font(.headline)
                                                .padding(.horizontal)
                                            
                                            Menu {
                                                Section(header: Text("Sort by")) {
                                                    Picker("Sort by", selection: $selectedSortOption) {
                                                        ForEach(PriceSortOption.allCases, id: \.self) { option in
                                                            Text(option.rawValue).tag(option)
                                                        }
                                                    }
                                                }
                                                
                                                Section(header: Text("Filter by Condition")) {
                                                    Picker("Condition", selection: $selectedCondition) {
                                                        ForEach(ConditionFilterOption.allCases, id: \.self) { option in
                                                            Text(option.rawValue).tag(option)
                                                        }
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                                    Text("Sort & Filter")
                                                }
                                                .foregroundColor(.blue)
                                                Spacer()
                                                .padding(.horizontal)
                                            }
                                            
                                            if noListingsFound {
                                                        VStack(spacing: 12) {
                                                            Text("No listings available for your selected vehicle and part.")
                                                                .font(.body)
                                                                .foregroundColor(.gray)
                                                                .multilineTextAlignment(.center)
                                                                .padding()

                                                            Button(action: {
                                                                redirectToExternalVendor()
                                                            }) {
                                                                Text("Search Online for \(selectedCategoryLabel)")
                                                                    .foregroundColor(.white)
                                                                    .padding()
                                                                    .frame(maxWidth: .infinity)
                                                                    .background(Color.blue)
                                                                    .cornerRadius(10)
                                                            }
                                                            .padding(.horizontal)
                                                        }
                                            } else {
                                                ForEach(sortedListings()) { listing in
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        if let urlString = listing.imageUrls.first,
                                                           let url = URL(string: urlString), !urlString.isEmpty {
                                                            
                                                            AsyncImage(url: url) { phase in
                                                                switch phase {
                                                                case .empty:
                                                                    ProgressView().frame(height: 200)
                                                                case .success(let image):
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(height: 200)
                                                                        .clipped()
                                                                        .cornerRadius(12)
                                                                case .failure:
                                                                    Image(systemName: "photo")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(height: 200)
                                                                        .foregroundColor(.gray)
                                                                @unknown default:
                                                                    EmptyView()
                                                                }
                                                            }
                                                        } else {
                                                            Text("No image available")
                                                                .frame(height: 200)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color.gray.opacity(0.2))
                                                                .cornerRadius(12)
                                                        }
                                                        
                                                        Text(listing.description)
                                                            .font(.subheadline)
                                                        Text("Condition: \(listing.condition)")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                        Text("Price: $\(listing.price)")
                                                            .font(.headline)
                                                            .foregroundColor(.blue)
                                                        Text("Phone: \(listing.phoneNumber)")
                                                            .font(.footnote)
                                                            .foregroundColor(.secondary)
                                                        
                                                        Button(action: {
                                                            cartManager.addToCart(listing)
                                                        }) {
                                                            Label("Add to Cart", systemImage: "cart.badge.plus")
                                                                .font(.footnote)
                                                                .foregroundColor(.white)
                                                                .padding(6)
                                                                .background(Color.blue)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                                    .padding()
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(12)
                                                    .padding(.horizontal)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Spacer().frame(height: geometry.safeAreaInsets.bottom)
                                }
                                .onAppear {
                                    loadVehiclesFromFirebase()
                                    loadAllListings()
                                    loadVehicleDataFromStorage()
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: CartView()) {
                                Image(systemName: "cart")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                            }

                            if !cartManager.cartItems.isEmpty {
                                Text("\(cartManager.cartItems.count)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
        }
    }
    /*
    var yearPicker: some View {
        Menu {
            ForEach(years, id: \.self) { year in
                Button { newVehicle.year = year } label: { Text(year) }
            }
        } label: {
            pickerLabel(text: newVehicle.year, placeholder: "Year")
        }
    }
    */
    var makePicker: some View {
        Menu {
            ForEach(makes, id: \.self) { make in
                Button {
                    newVehicle.make = make
                    newVehicle.model = ""
                    newVehicle.trim = ""
                } label: { Text(make) }
            }
        } label: {
            pickerLabel(text: newVehicle.make, placeholder: "Make")
        }
    }
    
    var modelPicker: some View {
        Group {
            if let models = modelsByMake[newVehicle.make] {
                Menu {
                    ForEach(models, id: \.self) { model in
                        Button {
                            newVehicle.model = model
                            newVehicle.trim = ""
                        } label: { Text(model) }
                    }
                } label: {
                    pickerLabel(text: newVehicle.model, placeholder: "Model")
                }
            }
        }
    }
    
    var trimPicker: some View {
        Group {
            if let trims = trimsByModel[newVehicle.model] {
                Menu {
                    ForEach(trims, id: \.self) { trim in
                        Button {
                            newVehicle.trim = trim
                        } label: { Text(trim) }
                    }
                } label: {
                    pickerLabel(text: newVehicle.trim, placeholder: "Trim")
                }
            }
        }
    }
    
    func pickerLabel(text: String, placeholder: String) -> some View {
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
    
    func loadVehicleDataFromStorage() {
        let storage = Storage.storage()
        let ref = storage.reference(withPath: "csvjson.json") // adjust based on actual path

        
        ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("❌ Error fetching vehicle data: \(error)")
                return
            }
            guard let data = data else { return }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var makeSet: Set<String> = []
                    var modelsDict: [String: Set<String>] = [:]
                    var trimsDict: [String: Set<String>] = [:]
                    
                    for entry in jsonArray {
                        guard let make = (entry["brand"] as? String)?.trimmingCharacters(in: .whitespaces),
                              let model = (entry["model"] as? String)?.trimmingCharacters(in: .whitespaces),
                              let trim = (entry["trim"] as? String)?.trimmingCharacters(in: .whitespaces)
                        else { continue }
                        
                        makeSet.insert(make)
                        modelsDict[make, default: []].insert(model)
                        trimsDict[model, default: []].insert(trim)
                    }
                    
                    makes = Array(makeSet).sorted()
                    modelsByMake = modelsDict.mapValues { Array($0).sorted() }
                    trimsByModel = trimsDict.mapValues { Array($0).sorted() }
                    
                    print("✅ Vehicle data loaded from Firebase Storage")
                }
            } catch {
                print("❌ Failed to parse JSON: \(error)")
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
           // "year": vehicle.year
        ]
        ref.child("users").child(userUID).child("vehicles").child(vehicle.id.uuidString)
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
                 //  let year = value["year"] as? String,
                   let id = UUID(uuidString: snap.key) {
                    let vehicle = Vehicle(id: id, make: make, model: model, trim: trim)
                    loadedVehicles.append(vehicle)
                }
            }
            vehicles = loadedVehicles
            print("✅ Loaded \(vehicles.count) vehicles from Firebase.")
        }
    }
    
    func deleteVehicleFromFirebase(vehicle: Vehicle) {
        guard !userUID.isEmpty else { return }
        let ref = Database.database().reference()
        ref.child("users").child(userUID).child("vehicles").child(vehicle.id.uuidString).removeValue()
        vehicles.removeAll { $0.id == vehicle.id }
    }
    
    func loadListings(for category: String) {
        selectedCategoryLabel = category
        showListings = true
        
        let ref = Database.database().reference()
        ref.child("listings").child(category.lowercased()).observeSingleEvent(of: .value) { snapshot in
            var fetchedListings: [Posting] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let value = snap.value as? [String: Any],
                   let phone = value["phoneNumber"] as? String,
                   let desc = value["description"] as? String,
                   let price = value["price"] as? String,
                   let condition = value["condition"] as? String,
                   let type = value["typeOfPart"] as? String,
                   let imageUrls = value["imageUrls"] as? [String] {
                    
                    let listing = Posting(phoneNumber: phone, description: desc, price: price, condition: condition, typeOfPart: type, imageUrls: imageUrls)
                    
                    if let vehicle = selectedVehicle {
                        if desc.lowercased().contains(vehicle.make.lowercased()) &&
                            desc.lowercased().contains(vehicle.model.lowercased()) &&
                            desc.lowercased().contains(vehicle.trim.lowercased()) {
                            fetchedListings.append(listing)
                        }
                    } else {
                        fetchedListings.append(listing)
                    }
                }
            }
            selectedCategoryListings = fetchedListings
            noListingsFound = fetchedListings.isEmpty

        }
    }
    
        func redirectToExternalVendor() {
            guard let selectedVehicle = selectedVehicle else { return }
            
            let make = selectedVehicle.make.replacingOccurrences(of: " ", with: "+")
            let model = selectedVehicle.model.replacingOccurrences(of: " ", with: "+")
            let trim = selectedVehicle.trim.replacingOccurrences(of: " ", with: "+")
            let part = selectedCategoryLabel.replacingOccurrences(of: " ", with: "+")
            
            let searchQuery = "\(make)+\(model)+\(trim)+\(part)"
            let urlString = "https://www.autozone.com/searchresult?searchText=\(searchQuery)"
            
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }

    
    func loadAllListings() {
        showListings = true
        selectedCategoryLabel = "All"
        selectedCategoryListings = []
        
        let ref = Database.database().reference().child("listings")
        ref.observeSingleEvent(of: .value) { snapshot in
            var allListings: [Posting] = []
            for category in snapshot.children {
                if let categorySnap = category as? DataSnapshot {
                    for child in categorySnap.children {
                        if let snap = child as? DataSnapshot,
                           let value = snap.value as? [String: Any],
                           let phone = value["phoneNumber"] as? String,
                           let desc = value["description"] as? String,
                           let price = value["price"] as? String,
                           let condition = value["condition"] as? String,
                           let type = value["typeOfPart"] as? String,
                           let imageUrls = value["imageUrls"] as? [String] {

                            print("Fetched image URLs: \(imageUrls)")

                            let listing = Posting(phoneNumber: phone, description: desc, price: price, condition: condition, typeOfPart: type, imageUrls: imageUrls)
                            allListings.append(listing)
                        }
                    }
                }
            }
            selectedCategoryListings = allListings
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
    private func sortedListings() -> [Posting] {
        var filtered = selectedCategoryListings
        
        if selectedCondition == .new {
            filtered = filtered.filter { $0.condition.lowercased() == "new" }
        } else if selectedCondition == .used {
            filtered = filtered.filter { $0.condition.lowercased() == "used" }
        }
        switch selectedSortOption {
        case .lowToHigh:
            return filtered.sorted { (Double($0.price) ?? 0) < (Double($1.price) ?? 0) }
        case .highToLow:
            return filtered.sorted { (Double($0.price) ?? 0) > (Double($1.price) ?? 0) }
        case .none:
            return filtered
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
