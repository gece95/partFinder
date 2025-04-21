import SwiftUI

struct ProfileRowItem: View {
    var icon: String
    var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.black)
    }
}

