// mhadiwidjaja/sparetrousers/SpareTrousers-a561ff476a166c8bc23b8d4c7bfb8fb50ec5c30f/SpareTrousers/View/HomeView.swift

import SwiftUI

struct HomeView: View {
    // ViewModel for HomeView's own state (like selectedTab, search text etc.)
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel

    private let topCornerRadius: CGFloat = 18

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.appOffWhite
                    .edgesIgnoringSafeArea(.all)

                content(for: homeViewModel.selectedTab, authViewModel: authViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                BottomNavBar(selectedTab: $homeViewModel.selectedTab)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(homeViewModel) // Provides HomeViewModel to children like MyRentalsView for its environment needs
    }

    @ViewBuilder
    private func content(for tab: Tab, authViewModel: AuthViewModel) -> some View {
        switch tab {
        case .home:
            VStack(spacing: 0) {
                TopNavBar(
                    searchText: $homeViewModel.searchText,
                    onSearchTapped: homeViewModel.performSearch
                )
                .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: topCornerRadius)

                        VStack(alignment: .leading, spacing: 20) {
                            CategoriesSection(categories: homeViewModel.categories, homeViewModel: homeViewModel)
                            ForYouSection(items: homeViewModel.displayedForYouItems)
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
            // Instantiate MyRentalsView and pass the homeViewModel
            MyRentalsView(homeViewModel: homeViewModel) // MODIFIED HERE

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
            .environmentObject(AuthViewModel())
            // homeViewModel is managed by @StateObject within HomeView,
            // and also provided to the environment for its children.
            .preferredColorScheme(.light)
    }
}
