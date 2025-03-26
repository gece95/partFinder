/*
 Welcome to partFinder team
 
 ContentView.swift
 Created by Emily Marrufo
 */
import SwiftUI
import Foundation
// MARK: - Vehicle Struct
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


// MARK: - ContentView
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()

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
            ZStack(alignment: .bottom) {
                (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {

                            // MARK: - Header
                            HStack {
                                Menu {
                                    ForEach(viewModel.cities, id: \.self) { city in
                                        Button(city) {
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
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)

                                Spacer()
                            }
                            .padding(.horizontal)

                            // MARK: - Vehicle Input
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

                            // MARK: - Vehicle Selector
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

                            // MARK: - Categories
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

                            Spacer().frame(height: 100)
                        }
                        .padding(.top)
                    }
                }

                // MARK: - Bottom Navigation Bar
                VStack(spacing: 4) {
                    Divider().background(Color.gray.opacity(0.3))
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                            Text("Sell")
                                .font(.caption)
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "house")
                                .font(.system(size: 20))
                            Text("Home")
                                .font(.caption)
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "person")
                                .font(.system(size: 20))
                            Text("Profile")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .foregroundColor(.gray)
                }

                // MARK: - Hidden NavigationLink
                NavigationLink(
                    destination: ListingListView(title: selectedCategoryLabel, listings: selectedCategoryListings),
                    isActive: $showListings
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Category Tile
struct CategoryItem: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
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
