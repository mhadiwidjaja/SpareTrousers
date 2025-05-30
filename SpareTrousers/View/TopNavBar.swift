import SwiftUI

struct TopNavBar: View {
    @Binding var searchText: String
    var onSearchTapped: () -> Void

    // pull the giant safe-area expression out into its own var:
    private var topInset: CGFloat {
        UIApplication.shared
          .connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .first?
          .windows
          .first { $0.isKeyWindow }?
          .safeAreaInsets.top
        ?? 0
    }

    let bottomCornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: topInset)

            HStack {
                Text("Home")
                    .font(.custom("MarkerFelt-Wide", size: 36))
                    .foregroundColor(.appWhite)
                    .shadow(color: .appBlack, radius: 1)
                    .shadow(color: .appBlack, radius: 1)
                    .shadow(color: .appBlack, radius: 1)
                    .shadow(color: .appBlack, radius: 1)
                    .shadow(color: .appBlack, radius: 1)
                Spacer()
                Image("SpareTrousers")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 50, height: 50)
            }
            .padding(.horizontal)

            HStack {
                TextField("Search", text: $searchText)
                  .padding(10)
                  .background(Color.appWhite)
                  .cornerRadius(8)
                  .shadow(radius: 1)

                Button(action: onSearchTapped) {
                  Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.appBlack)
                    .padding(10)
                    .background(Color.appWhite)
                    .cornerRadius(8)
                    .shadow(radius: 1)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
        .background(Color.appBlue.edgesIgnoringSafeArea(.top))
        .clipShape(RoundedCorner(
            radius: bottomCornerRadius,
            corners: [.bottomLeft, .bottomRight]
        ))
    }
}
