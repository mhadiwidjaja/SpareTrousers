import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    private let topCornerRadius: CGFloat = 18

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.appOffWhite
                  .edgesIgnoringSafeArea(.all)

                // ③ tiny switch helper
                content(for: viewModel.selectedTab)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .navigationBarHidden(true)
                  .navigationBarBackButtonHidden(true)

                BottomNavBar(selectedTab: $viewModel.selectedTab)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // ③ Type‐erase the tab switch:
    @ViewBuilder
    private func content(for tab: Tab) -> some View {
        switch tab {
        case .home:
            VStack(spacing: 0) {
                TopNavBar(
                  searchText: $viewModel.searchText,
                  onSearchTapped: viewModel.performSearch
                )
                .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: topCornerRadius)

                        VStack(alignment: .leading, spacing: 20) {
                            // **Make sure these are your real properties**
                            CategoriesSection(categories: viewModel.categories)
                            NearYouSection(items: viewModel.displayedNearYouItems)
                            Spacer(minLength: 80)
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.appWhite)
                .clipShape(RoundedCorner(
                  radius: topCornerRadius,
                  corners: [.topLeft, .topRight]
                ))
                .padding(.top, -50)
                .background(Color.appWhite)
                .ignoresSafeArea(edges: .bottom)
            }

        case .myRentals:
            MyRentalsView()

        case .inbox:
            InboxView()

        case .account:
            AccountView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
          // Optional: show both light and dark modes
          .preferredColorScheme(.light)
    }
}
