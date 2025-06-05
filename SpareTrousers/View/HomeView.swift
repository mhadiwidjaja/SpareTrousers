// mhadiwidjaja/sparetrousers/SpareTrousers-a561ff476a166c8bc23b8d4c7bfb8fb50ec5c30f/SpareTrousers/View/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private let topCornerRadius: CGFloat = 18

    var body: some View {
            if horizontalSizeClass == .compact {
                NavigationView {
                    ZStack(alignment: .bottom) {
                        Color.appOffWhite
                            .edgesIgnoringSafeArea(.all)

                        content(for: homeViewModel.selectedTab, currentAuthViewModel: authViewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                        BottomNavBar(selectedTab: $homeViewModel.selectedTab)
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(homeViewModel)
            } else {
                NavigationView {
                    SidebarView(selectedTab: $homeViewModel.selectedTab, homeViewModel: homeViewModel, authViewModel: authViewModel)
                    content(for: homeViewModel.selectedTab, currentAuthViewModel: authViewModel)
                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .environmentObject(homeViewModel)
            }
        }

    @ViewBuilder
        private func content(for tab: Tab, currentAuthViewModel: AuthViewModel) -> some View {
            switch tab {
            case .home:
                if horizontalSizeClass == .compact {
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
                } else {
                    HomeTabPage(homeViewModel: homeViewModel, authViewModel: currentAuthViewModel)
                }

            case .myRentals:
                MyRentalsView(homeViewModel: homeViewModel, authViewModel: currentAuthViewModel)
                    .environmentObject(homeViewModel)
            case .inbox:
                InboxView()
                    .environmentObject(currentAuthViewModel)
            case .account:
                AccountView()
                    .environmentObject(currentAuthViewModel)
            }
        }
    }


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
            let authViewModel = AuthViewModel()
            
            HomeView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
                .previewDevice("iPhone 16 Pro")

            HomeView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
}
