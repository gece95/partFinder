//
//  ProfileRowItem.swift
//  partFinder
//
//  Created by Emily marrufo on 4/15/25.
//
import SwiftUI

struct ProfileRowItem: View {
    let icon: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(label)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

