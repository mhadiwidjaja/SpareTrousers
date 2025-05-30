import SwiftUI


struct HomeView: View {
    // ViewModel for HomeView's own state (like selectedTab, search text etc.)
    @StateObject private var homeViewModel = HomeViewModel()

    // AuthViewModel to be passed to AccountView and potentially other views
    // This instance will be created once for HomeView and its children.
    @StateObject private var authViewModel = AuthViewModel() // Create and own AuthViewModel

    private let topCornerRadius: CGFloat = 18

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.appOffWhite // Ensure .appOffWhite is defined
                  .edgesIgnoringSafeArea(.all)

                // Pass authViewModel to the content view builder
                content(for: homeViewModel.selectedTab, authViewModel: authViewModel)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .navigationBarHidden(true)
                  .navigationBarBackButtonHidden(true)

                // BottomNavBar uses homeViewModel for selectedTab
                BottomNavBar(selectedTab: $homeViewModel.selectedTab)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Provide AuthViewModel to the entire hierarchy within HomeView's NavigationView
        // This makes it available to AccountView and any other view that might need it.
        // Alternatively, you could pass it more selectively if only AccountView needs it.
        // However, if other tabs might also need auth state, providing it here is common.
        .environmentObject(authViewModel)
    }

    @ViewBuilder
    private func content(for tab: Tab, authViewModel: AuthViewModel) -> some View { // Accept authViewModel
        switch tab {
        case .home:
            VStack(spacing: 0) {
                TopNavBar( // Assuming TopNavBar exists
                  searchText: $homeViewModel.searchText,
                  onSearchTapped: homeViewModel.performSearch
                )
                .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: topCornerRadius)

                        VStack(alignment: .leading, spacing: 20) {
                            CategoriesSection(categories: homeViewModel.categories) // Assuming CategoriesSection exists
                            NearYouSection(items: homeViewModel.displayedNearYouItems) // Assuming NearYouSection exists
                            Spacer(minLength: 80)
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.appWhite) // Ensure .appWhite is defined
                .clipShape(RoundedCorner( // Assuming RoundedCorner exists
                  radius: topCornerRadius,
                  corners: [.topLeft, .topRight]
                ))
                .padding(.top, -50) // Adjust as per your UI
                .background(Color.appWhite)
                .ignoresSafeArea(edges: .bottom)
            }
            // If Home content itself needs AuthViewModel, it can access it from the environment
            // .environmentObject(authViewModel) // Or pass explicitly if preferred

        case .myRentals:
            MyRentalsView() // Assuming MyRentalsView exists
            // .environmentObject(authViewModel) // If MyRentalsView needs it

        case .inbox:
            InboxView() // Assuming InboxView exists
            // .environmentObject(authViewModel) // If InboxView needs it

        case .account:
            AccountView()
            // AccountView will now receive authViewModel from the .environmentObject on NavigationView
            // No need to explicitly pass it here if provided at a higher level like NavigationView.
            // However, if you choose not to put .environmentObject on NavigationView,
            // you would do it here: .environmentObject(authViewModel)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
          // Optional: show both light and dark modes
          .preferredColorScheme(.light)
          // AuthViewModel is created by HomeView itself using @StateObject,
          // so the preview should work without explicitly providing it here,
          // unless sub-components in the preview directly require it from this level.
    }
}
