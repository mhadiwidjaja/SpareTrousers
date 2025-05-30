//
//  HomeView.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel() // Your HomeViewModel
    let topSectionCornerRadius: CGFloat = 18

    var body: some View {
        // The root NavigationView for enabling navigation to ItemDetailView
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.appOffWhite // Define Color.appOffWhite if not already
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    Group {
                        switch viewModel.selectedTab {
                        case .home:
                            VStack(spacing: 0) {
                                TopNavBar(
                                    searchText: $viewModel.searchText,
                                    onSearchTapped: viewModel.performSearch
                                )
                                .ignoresSafeArea(edges: .top)

                                ScrollView {
                                    VStack(spacing: 0) {
                                        Spacer().frame(height: topSectionCornerRadius)
                                        VStack(alignment: .leading, spacing: 20) {
                                            CategoriesSection(categories: viewModel.categories)
                                            // Pass viewModel to NearYouSection if it needs to perform actions
                                            // or if items are directly from viewModel.
                                            NearYouSection(items: viewModel.nearYouItems)
                                            Spacer(minLength: 80) // Ensure enough space for BottomNavBar
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .background(Color.appWhite) // Define Color.appWhite
                                .clipShape(
                                    RoundedCorner(
                                        radius: topSectionCornerRadius,
                                        corners: [.topLeft, .topRight]
                                    )
                                )
                                .padding(.top, -60) // Adjust to pull ScrollView under TopNavBar
                            }
                            .background(Color.appWhite) // Ensure background consistency
                            .ignoresSafeArea(edges: .bottom)

                        case .myRentals:
                            MyRentalsView() // Assuming this view exists
                        case .inbox:
                            InboxView()     // Assuming this view exists
                        case .account:
                            AccountView()   // Assuming this view exists
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // Hide the default navigation bar of the NavigationView
                // because we have a custom TopNavBar and BottomNavBar.
                // The navigation capabilities are still active for NavigationLink.
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true) // Hides back button if one were to appear from this NavView

                // Conditionally show BottomNavBar based on selectedTab
                // if viewModel.selectedTab == .home { // Or other tabs as needed
                    BottomNavBar(selectedTab: $viewModel.selectedTab)
                // }
            }
            // .navigationBarHidden(true) // Already applied to inner content
            // .navigationBarBackButtonHidden(true) // Already applied
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recommended for the root NavigationView
    }
}

// MARK: - Subviews for HomeView (Copied from your HomeView.swift, with modifications for Navigation)

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct TopNavBar: View {
    @Binding var searchText: String
    var onSearchTapped: () -> Void
    let bottomCornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 10) {
            // Adjusted Spacer for status bar dynamically
            Spacer().frame(height: UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first?.safeAreaInsets.top ?? 0)

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
                Image("SpareTrousers") // Ensure this image is in your assets
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
        .background(Color.appBlue.edgesIgnoringSafeArea(.top)) // Ensure .appBlue is defined
        .clipShape(RoundedCorner(radius: bottomCornerRadius, corners: [.bottomLeft, .bottomRight]))
    }
}

struct CategoriesSection: View {
    let categories: [CategoryItem] // From HomeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack) // Ensure .appBlack is defined
                .padding(.leading, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories) { category in
                        CategoryView(category: category)
                    }
                }
                .padding(.vertical, 5) // Added padding for better spacing
            }
        }
    }
}

struct CategoryView: View {
    let category: CategoryItem // From your CategoryItem.swift

    var body: some View {
        VStack {
            ZStack {
                category.color
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.appWhite) // Ensure .appWhite is defined
            }
            Text(category.name)
                .font(.caption)
                .foregroundColor(.appBlack) // Ensure .appBlack is defined
        }
    }
}

struct NearYouSection: View {
    let items: [DisplayItem] // From HomeViewModel, should be of type DisplayItem
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Near You")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack)
                .padding(.leading, 5)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    // NavigationLink to ItemDetailView
                    NavigationLink(destination: ItemDetailView(item: item)) { // ItemDetailView is from the other immersive
                        ItemCardView(item: item)
                    }
                    // .buttonStyle(PlainButtonStyle()) // Uncomment if you want to remove default link styling from the card
                }
            }
        }
    }
}

struct ItemCardView: View {
    let item: DisplayItem // From your DisplayItem.swift
    private var twoLineTextHeight: CGFloat {
        // A more robust way to calculate height for two lines
        let font = UIFont.preferredFont(forTextStyle: .headline) // Or your custom font
        return (font.lineHeight * 2) + font.leading // Adjust based on actual font and leading
    }

    var body: some View {
        VStack(alignment: .leading) { // Removed spacing: 0 to use default or explicit spacing if needed
            Image(item.imageName) // Ensure this image is in your assets or loaded correctly
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 177, height: 177) // Consider making this more dynamic
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.appBlack)
                    .lineLimit(2)
                    // Ensure text can actually take up two lines if needed.
                    .frame(minHeight: twoLineTextHeight, alignment: .topLeading)
                
                Text(item.rentalPrice)
                    .font(.subheadline)
                    .foregroundColor(Color.appOffGray) // Ensure .appOffGray is defined
            }
            // Removed .padding(10) from here as it was on the outer VStack in your original
        }
        .padding(10) // This was on the outer VStack in your original code
        // .background(Color(UIColor.systemBackground)) // Add a background if needed for the card itself
        .cornerRadius(10) // This was on the outer VStack in your original code
        // .shadow(radius: 1) // Add shadow if desired
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab // Tab enum from HomeViewModel

    var body: some View {
        HStack {
            Spacer()
            BottomNavButton(iconName: "house.fill", title: "Home", isSelected: selectedTab == .home) { selectedTab = .home }
            Spacer()
            BottomNavButton(iconName: "list.bullet.rectangle.fill", title: "My Rentals", isSelected: selectedTab == .myRentals) { selectedTab = .myRentals }
            Spacer()
            BottomNavButton(iconName: "envelope.fill", title: "Inbox", isSelected: selectedTab == .inbox) { selectedTab = .inbox }
            Spacer()
            BottomNavButton(iconName: "person.fill", title: "Account", isSelected: selectedTab == .account) { selectedTab = .account }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.appOrange) // Ensure .appOrange is defined
        .cornerRadius(18)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .padding(.horizontal, 20)
        // Add padding for the bottom safe area if not handled by ignoresSafeArea on ScrollView
        .padding(.bottom, UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.safeAreaInsets.bottom ?? 0)
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
                    .font(.system(size: 32)) // Consider adjusting size
                    .foregroundColor(isSelected ? .appWhite : .appBlack)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .appWhite : .appBlack)
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HomeViewModel()) // Provide ViewModel for preview if needed by subviews directly
    }
}
