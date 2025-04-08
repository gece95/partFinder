/*
 Welcome to partFinder team

 ContentView.swift
 Created by Emily Marrufo
 */

import SwiftUI
import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase


struct Vehicle: Identifiable, Equatable {
    let id = UUID()
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

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""

    @State private var newVehicle = Vehicle(make: "", model: "", trim: "", year: "")
    @State private var vehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?

    @State private var selectedCategoryListings: [Listing] = []
    @State private var showListings = false
    @State private var selectedCategoryLabel: String = ""

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                            .edgesIgnoringSafeArea(.all)

                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 20) {
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
                                    }

                                    Spacer()

                                    Text("partFinder")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)

                                    Spacer()
                                }
                                .padding(.horizontal)

                                if let zip = locationManager.zipCode {
                                    Text("ZIP Code: \(zip)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                }

                                // Vehicle Input
                                VStack(spacing: 10) {
                                    TextField("Make", text: $newVehicle.make)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    TextField("Model", text: $newVehicle.model)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    TextField("Trim", text: $newVehicle.trim)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    TextField("Year", text: $newVehicle.year)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("Add Vehicle") {
                                        guard !newVehicle.make.isEmpty,
                                              !newVehicle.model.isEmpty,
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

                                // Vehicle Selector
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

                                // Categories
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
                            }
                        }
                    }
                }
            }
            .navigationTitle("partFinder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoggedIn {
                        NavigationLink(destination: ProfileView()) {
                            Text("Profile")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        NavigationLink(destination: RegisterView()) {
                            Text("Login")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black)
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
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
}

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var message = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)

                Button("Create Account") {
                    UserManager().registerUser(email: email, password: password, name: name) { result in
                        switch result {
                        case .success:
                            userName = name
                            userEmail = email
                            isLoggedIn = true
                            message = "✅ Account created!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        case .failure(let error):
                            message = "❌ \(error.localizedDescription)"
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.top)
        }
    }
}

struct ProfileView: View {
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text("Name: \(userName)")
                    .foregroundColor(.white)

                Text("Email: \(userEmail)")
                    .foregroundColor(.white)

                Button("Logout") {
                    try? Auth.auth().signOut()
                    isLoggedIn = false
                    userName = ""
                    userEmail = ""
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
