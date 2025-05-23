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
    @Published var nearYouItems: [DisplayItem] = []
    @Published var selectedTab: Tab = .home

    init() {
        fetchCategories()
        fetchNearYouItems()
    }

    func fetchCategories() {
        // Placeholder data - replace with actual data fetching logic
        self.categories = [
            CategoryItem(name: "Fashion", iconName: "tshirt.fill", color: Color.purple.opacity(0.8)),
            CategoryItem(name: "Cooking", iconName: "fork.knife.circle.fill", color: Color.orange.opacity(0.8)),
            CategoryItem(name: "Tools", iconName: "wrench.and.screwdriver.fill", color: Color.gray.opacity(0.8)),
            CategoryItem(name: "Toys", iconName: "gamecontroller.fill", color: Color.yellow.opacity(0.8)),
            CategoryItem(name: "Outdoor", iconName: "leaf.fill", color: Color.green.opacity(0.8)),
            CategoryItem(name: "Electronics", iconName: "tv.and.hifispeaker.fill", color: Color.blue.opacity(0.8))
        ]
    }

    func fetchNearYouItems() {
        // Placeholder data - replace with actual data fetching logic
        self.nearYouItems = [
            DisplayItem(name: "Orange and Blue Trousers", imageName: "DummyProduct", rentalPrice: "Rp 20.000 /day"),
            DisplayItem(name: "Cool Red Jacket", imageName: "DummyProduct", rentalPrice: "Rp 30.000 /day"),
            DisplayItem(name: "Vintage Camera", imageName: "DummyProduct", rentalPrice: "Rp 50.000 /day"),
            DisplayItem(name: "Camping Tent", imageName: "DummyProduct", rentalPrice: "Rp 75.000 /day")
        ]
    }

    func performSearch() {
        print("Searching for: \(searchText)")
        // Implement search logic here
    }
}
