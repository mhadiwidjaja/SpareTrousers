import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Tab

    private var bottomInset: CGFloat {
        UIApplication.shared
          .connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .first?
          .windows
          .first { $0.isKeyWindow }?
          .safeAreaInsets.bottom
        ?? 0
    }

    var body: some View {
        HStack {
            Spacer()
            BottomNavButton(
              iconName: "house.fill", title: "Home",
              isSelected: selectedTab == .home
            ) { selectedTab = .home }
            Spacer()
            BottomNavButton(
              iconName: "list.bullet.rectangle.fill",
              title: "My Rentals",
              isSelected: selectedTab == .myRentals
            ) { selectedTab = .myRentals }
            Spacer()
            BottomNavButton(
              iconName: "envelope.fill", title: "Inbox",
              isSelected: selectedTab == .inbox
            ) { selectedTab = .inbox }
            Spacer()
            BottomNavButton(
              iconName: "person.fill", title: "Account",
              isSelected: selectedTab == .account
            ) { selectedTab = .account }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.appOrange)
        .cornerRadius(18)
        .shadow(color: .appBlack, radius: 1)
        .padding(.horizontal, 20)
        .padding(.bottom, bottomInset)
    }
}

struct BottomNavButton: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                  .font(.system(size: 32))
                  .foregroundColor(isSelected ? .appWhite : .appBlack)
                Text(title)
                  .font(.caption2)
                  .foregroundColor(isSelected ? .appWhite : .appBlack)
            }
        }
    }
}
