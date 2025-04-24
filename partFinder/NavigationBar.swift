import SwiftUI

struct BottomNavBar: View {
    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: VendorsView()) {
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                    Text("Sell")
                        .font(.caption)
                }
            }
            Spacer()
            NavigationLink(destination: ContentView()) {
                VStack(spacing: 4) {
                    Image(systemName: "house")
                        .font(.system(size: 20))
                    Text("Home")
                        .font(.caption)
                }
            }
            Spacer()
            NavigationLink(destination: ProfileView(viewModel: ProfileViewModel())) {
                VStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.system(size: 20))
                    Text("Profile")
                        .font(.caption)
                }
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.black)
        .foregroundColor(.gray)
    }
}

struct BaseView<Content: View>: View {
    var title: String
    var showProfileButton: Bool
    var content: Content

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = ""
    @AppStorage("userEmail") var userEmail = ""

    init(title: String = "", showProfileButton: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self.showProfileButton = showProfileButton
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))

                BottomNavBar()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
            }
            .navigationTitle(title)
        }
    }
}



struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar()
    }
}
