//
//  HomeViewModel.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//


// ViewModels/HomeViewModel.swift
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var categories: [CategoryItem] = []
    private var allNearYouItems: [DisplayItem] = []
    @Published var displayedNearYouItems: [DisplayItem] = []
    @Published var selectedTab: Tab = .home
    @Published var isSearchActive: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchCategories()
        generateDummyData() // TODO: Remove this once app is completed
        displayedNearYouItems = allNearYouItems
    }

    func fetchCategories() {
        // Placeholder data - replace with actual data fetching logic
        self.categories = [
            CategoryItem(
                name: "Fashion",
                iconName: "tshirt.fill",
                color: Color.purple.opacity(0.8)
            ),
            CategoryItem(
                name: "Cooking",
                iconName: "fork.knife.circle.fill",
                color: Color.orange.opacity(0.8)
            ),
            CategoryItem(
                name: "Tools",
                iconName: "wrench.and.screwdriver.fill",
                color: Color.gray.opacity(0.8)
            ),
            CategoryItem(
                name: "Toys",
                iconName: "gamecontroller.fill",
                color: Color.yellow.opacity(0.8)
            ),
            CategoryItem(
                name: "Outdoor",
                iconName: "leaf.fill",
                color: Color.green.opacity(0.8)
            ),
            CategoryItem(
                name: "Electronics",
                iconName: "tv.and.hifispeaker.fill",
                color: Color.blue.opacity(0.8)
            )
        ]
    }
    
    func generateDummyData() {
        let baseNames = [
            "Orange and Blue Trousers", "Vintage Orange", "Modern Black", "Comfy Cotton",
            "Slim Fit Denim", "Relaxed Linen", "Cargo Style", "Formal Wool",
            "Sporty Track", "Patterned Silk", "Checked Tweed", "Corduroy Comfort",
            "Summer Shorts", "Winter Warmers", "Utility Khaki", "Designer Velvet"
        ]
        let itemType = "Trousers"
        let image = "DummyProduct"

        var items: [DisplayItem] = []
        for _ in 0..<30 {
            let randomBaseName = baseNames.randomElement() ?? "Cool"
            let itemName = "\(randomBaseName) \(itemType)"
            let rentalPrice = "Rp \(Int.random(in: 15...100)).000 /day"
            items
                .append(
                    DisplayItem(
                        name: itemName,
                        imageName: image,
                        rentalPrice: rentalPrice
                    )
                )
        }
        self.allNearYouItems = items
    }
    
    func performSearch() {
        print("Search button clicked. Searching for: \(searchText)")
        
        if searchText.isEmpty {
            clearSearch()
            return
        }
        
        isSearchActive = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = self.allNearYouItems.filter { item in
                item.name.localizedCaseInsensitiveContains(self.searchText)
            }
            DispatchQueue.main.async {
                self.displayedNearYouItems = filtered
                if filtered.isEmpty {
                    print("No items found for '\(self.searchText)'")
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        isSearchActive = false // Mark search as inactive
        displayedNearYouItems = allNearYouItems
        print("Search cleared")
    }
}
