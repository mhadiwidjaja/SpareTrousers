//
//  SidebarView.swift
//  SpareTrousers
//
//  Created by student on 05/06/25.
//


import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: Tab
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        List {
            Text("Spare Trousers")
                .font(.largeTitle)
                .padding(.bottom)

            NavigationLink(destination: content(for: .home, authViewModel: authViewModel).environmentObject(homeViewModel)) {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)

            NavigationLink(destination: content(for: .myRentals, authViewModel: authViewModel).environmentObject(homeViewModel)) {
                Label("My Rentals", systemImage: "list.bullet.rectangle.fill")
            }
            .tag(Tab.myRentals)

            NavigationLink(destination: content(for: .inbox, authViewModel: authViewModel).environmentObject(homeViewModel)) {
                Label("Inbox", systemImage: "envelope.fill")
            }
            .tag(Tab.inbox)

            NavigationLink(destination: content(for: .account, authViewModel: authViewModel).environmentObject(homeViewModel)) {
                Label("Account", systemImage: "person.fill")
            }
            .tag(Tab.account)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
        // Ensure selectedTab is updated if NavigationView itself handles selection
        // For direct control, we might need to adjust how selection drives the detail view
        // This setup implies the detail view is managed by the HomeView's selectedTab
    }

    // Helper to get content for the detail view, similar to HomeView
    @ViewBuilder
    private func content(for tab: Tab, authViewModel: AuthViewModel) -> some View {
        // This is a simplified way to route. In HomeView, this content function is more complete.
        // For the sidebar, these links will push to the detail area.
        // The actual view switching logic might remain centralized in HomeView's main body.
        // For this example, assume content(for:tab) is correctly defined in HomeView
        // and these NavigationLinks correctly target the detail pane.

        // Correctly provide the views for the detail pane
        switch tab {
        case .home:
            // This re-uses the iPhone's tab content structure for iPad's detail view.
            // We need to ensure TopNavBar is handled correctly in this context for iPad.
            // For simplicity, let's assume HomeView's content function will be adapted.
            // For now, let's use placeholders or the actual views.
            HomeTabPage(homeViewModel: homeViewModel, authViewModel: authViewModel)
        case .myRentals:
            MyRentalsView(homeViewModel: homeViewModel, authViewModel: authViewModel)
        case .inbox:
            InboxView().environmentObject(authViewModel) // Assuming InboxView gets authViewModel
        case .account:
            AccountView().environmentObject(authViewModel) // Assuming AccountView gets authViewModel
        }
    }
}

// This is a placeholder for the Home tab content to be used in the sidebar context.
// You might need to refactor HomeView's content to be more reusable.
struct HomeTabPage: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    private let topCornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 0) {
            // On iPad, TopNavBar might be part of this detail view or a global nav bar.
            // For simplicity, we include it here conditionally if not handled globally.
            if horizontalSizeClass == .regular { // iPad
                 TopNavBar(
                     searchText: $homeViewModel.searchText,
                     onSearchTapped: homeViewModel.performSearch
                 )
                 .ignoresSafeArea(edges: .top)
            }

            ScrollView {
                VStack(spacing: 0) {
                    if horizontalSizeClass == .regular { // iPad
                        Spacer().frame(height: topCornerRadius)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        CategoriesSection(categories: homeViewModel.categories, homeViewModel: homeViewModel)
                        ForYouSection(items: homeViewModel.displayedForYouItems)
                        Spacer(minLength: 80) // Existing spacer
                    }
                    .padding(.horizontal) // Existing padding
                }
            }
            .background(Color.appWhite)
            .clipShape(RoundedCorner(
                radius: topCornerRadius,
                corners: [.topLeft, .topRight]
            ))
            .padding(.top, horizontalSizeClass == .regular ? -50 : 0) // Conditional adjustment for iPad
            .background(Color.appWhite)
            .ignoresSafeArea(edges: .bottom)
        }
        .environmentObject(homeViewModel)
        .environmentObject(authViewModel)
    }
}
