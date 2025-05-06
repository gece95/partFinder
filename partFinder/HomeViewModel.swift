import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedCity: String = "Location"
    @Published var selectedCar: String? = nil

    let cities = ["Los Angeles", "San Diego", "San Jose", "Sacramento", "Fresno"]
    let carBrands = ["Toyota", "Honda", "Tesla", "Ford", "Kia", "Hyundai"]

    let categories = [
        Category(icon: "engine_icon", label: "Engines"),
        Category(icon: "battery_icon", label: "Batteries"),
        Category(icon: "brake_icon", label: "Brakes"),
        Category(icon: "fluids_icon", label: "Fluids"),
        Category(icon: "turbo_icon", label: "Turbocharger"),
        Category(icon: "gasket_icon", label: "Gaskets")
    ]
}
