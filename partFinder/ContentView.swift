/*
 Welcome to partFinder team
 
 ContentView.swift
 Created by Emily Marrufo
 */
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()

    // Layout for category grid: 3 columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // App background based on dark mode or default black
            (colorScheme == .dark ? Color("DarkBackground") : Color.black)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {

                        
                        HStack {
                            // City Filter
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
                                        .foregroundColor(.gray) // dark mode
                                    Text(viewModel.selectedCity)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()

                            // App name
                            Text("partFinder")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)

                            Spacer()
                        }
                        .padding(.horizontal)

                        // MARK: - Vehicle Dropdown
                        Menu {
                            ForEach(viewModel.carBrands, id: \.self) { car in
                                Button {
                                    viewModel.selectedCar = car
                                } label: {
                                    Text(car)
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))

                                Text(viewModel.selectedCar ?? "Select Vehicle")
                                    .foregroundColor(.primary)
                                    .font(.body)

                                HStack {
                                    Spacer()
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.trailing)
                                }
                            }
                            .frame(height: 45)
                            .padding(.horizontal)
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
                                    CategoryItem(icon: category.icon, label: category.label)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 100) // space for bottom tab
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
        }
    }
}

// MARK: - Reusable Category Tile
struct CategoryItem: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .frame(width: 40, height: 40)
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

