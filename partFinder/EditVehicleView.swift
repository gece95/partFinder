//
//  EditVehicleView.swift
//  partFinder
//
//  Created by Zoe Hazan on 4/21/25.
//

import Foundation
import SwiftUI

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss

    @State var vehicle: Vehicle
    var onSave: (Vehicle) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Vehicle")) {
                    TextField("Year", text: $vehicle.year)
                        .keyboardType(.numberPad)
                    TextField("Make", text: $vehicle.make)
                    TextField("Model", text: $vehicle.model)
                    TextField("Trim", text: $vehicle.trim)
                }

                Section {
                    Button("Save Changes") {
                        onSave(vehicle)
                        dismiss()
                    }
                    .foregroundColor(.blue)

                    Button("Delete Vehicle") {
                        onDelete()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

