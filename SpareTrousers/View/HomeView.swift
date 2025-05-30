//
//  HomeView.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    let topSectionCornerRadius: CGFloat = 18

    var body: some View {
        ZStack(alignment: .bottom) {            Color.appOffWhite
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
                            .ignoresSafeArea(
                                edges: .top
                            )

                            ScrollView {
                                VStack(spacing: 0) {
                                    Spacer()
                                        .frame(height: topSectionCornerRadius)
                                    VStack(alignment: .leading, spacing: 20) {
                                        CategoriesSection(
                                            categories: viewModel.categories
                                        )
                                        NearYouSection(
                                            items: viewModel.displayedNearYouItems,
                                            currentSearchText: viewModel.searchText,
                                            isSearchActive: viewModel.isSearchActive,
                                            onClearSearch: {
                                                viewModel.clearSearch()
                                            }
                                        )
                                        Spacer(minLength: 80)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .background(Color.appWhite)
                            .clipShape(
                                RoundedCorner(
                                    radius: topSectionCornerRadius,
                                    corners: [.topLeft, .topRight]
                                )
                            )
                            .padding(.top, -60)
                        }
                        .background(Color.appWhite)
                        .ignoresSafeArea(edges: .bottom)   

                    case .myRentals:
                        MyRentalsView()

                    case .inbox:
                        InboxView()

                    case .account:
                        AccountView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            BottomNavBar(selectedTab: $viewModel.selectedTab)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}



struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TopNavBar: View {
    @Binding var searchText: String
    var onSearchTapped: () -> Void
    let bottomCornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 50)
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
        .clipShape(
            RoundedCorner(
                radius: bottomCornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
        )
    }
}

struct CategoriesSection: View {
    let categories: [CategoryItem]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack)
                .padding(.leading, 5)


            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories) { category in
                        CategoryView(category: category)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct CategoryView: View {
    let category: CategoryItem

    var body: some View {
        VStack {
            ZStack {
                category.color
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.appWhite)
            }
            Text(category.name)
                .font(.caption)
                .foregroundColor(.appBlack)
        }
    }
}

struct NearYouSection: View {
    let items: [DisplayItem]
    let currentSearchText: String
    let isSearchActive: Bool
    let onClearSearch: () -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(
                    isSearchActive ? "\"\(currentSearchText)\"" : "Near You"
                )
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(Color.appBlack)
                    
                Spacer()
                    
                if isSearchActive {
                    Button(action: onClearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(
                                Color.appOffGray
                            )
                    }
                }
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)

            if items.isEmpty {
                Text(
                    isSearchActive ? "No items match \"\(currentSearchText)\"." : "No items available near you currently."
                )
                .foregroundColor(Color.appOffGray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        ItemCardView(
                            item: item
                        )
                    }
                }
            }
        }
    }
}

struct ItemCardView: View {
    let item: DisplayItem
    private var twoLineTextHeight: CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .headline)
        return (font.lineHeight * 2) + font.leading
    }

    var body: some View {
        VStack(alignment: .leading) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(
                    contentMode: .fill
                )
                .frame(width: 177, height: 177)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.appBlack)
                    .lineLimit(2)
                    .frame(minHeight: twoLineTextHeight, alignment: .topLeading)
                Text(item.rentalPrice)
                    .font(.subheadline)
                    .foregroundColor(Color.appOffGray)
            }
        }
        .padding(10)
        .cornerRadius(10)
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Spacer()
            BottomNavButton(
                iconName: "house.fill",
                title: "Home",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            Spacer()
            BottomNavButton(
                iconName: "list.bullet.rectangle.fill",
                title: "My Rentals",
                isSelected: selectedTab == .myRentals
            ) {
                selectedTab = .myRentals
            }
            Spacer()
            BottomNavButton(
                iconName: "envelope.fill",
                title: "Inbox",
                isSelected: selectedTab == .inbox
            ) {
                selectedTab = .inbox
            }
            Spacer()
            BottomNavButton(
                iconName: "person.fill",
                title: "Account",
                isSelected: selectedTab == .account
            ) {
                selectedTab = .account
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.appOrange)
        .cornerRadius(18)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .shadow(color: .appBlack, radius: 1)
        .padding(.horizontal, 20)
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


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
