//
//  HomeViewModel.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//

// ViewModels/HomeViewModel.swift
import SwiftUI
import Combine
import FirebaseAuth // For user session, if needed for ownerUid later
import FirebaseDatabase // For Realtime Database

//class HomeViewModel: ObservableObject {
//    // MARK: - Published Properties for UI State
//    @Published var searchText: String = ""
//    @Published var isSearchActive: Bool = false
//
//    @Published var categories: [CategoryItem] = []
//    @Published var selectedCategoryId: Int? = nil
//    @Published var selectedCategoryName: String? = nil
//
//    @Published var displayedNearYouItems: [DisplayItem] = []
//    
//    @Published var selectedTab: Tab = .home
//    @Published var isLoadingItems: Bool = false
//    @Published var errorMessage: String? = nil
//
//    // MARK: - Private Properties
//    private var allFetchedItems: [DisplayItem] = []
//    private var dbRef: DatabaseReference!
//    private var itemsListenerHandle: DatabaseHandle?
//    private var cancellables = Set<AnyCancellable>()
//
//    // MARK: - Initialization
//    init() {
//        dbRef = Database.database().reference()
//        
//        initializeLocalCategories()
//        fetchItemsFromFirebase()
//    }
//
//    deinit {
//        if let handle = itemsListenerHandle {
//            dbRef.child("items").removeObserver(withHandle: handle)
//        }
//        print("HomeViewModel deinitialized and Firebase item listener removed.")
//    }
//
//    // MARK: - Local Category Initialization
//    func initializeLocalCategories() {
//        self.categories = [
//            CategoryItem(
//                id: 1,
//                name: "Fashion",
//                iconName: "tshirt.fill",
//                color: Color.appBlue.opacity(0.7)
//            ),
//            CategoryItem(
//                id: 2,
//                name: "Cooking",
//                iconName: "fork.knife.circle.fill",
//                color: Color.appOrange.opacity(0.7)
//            ),
//            CategoryItem(
//                id: 3,
//                name: "Tools",
//                iconName: "wrench.and.screwdriver.fill",
//                color: Color.appOffGray.opacity(0.7)
//            ),
//            CategoryItem(
//                id: 4,
//                name: "Toys",
//                iconName: "gamecontroller.fill",
//                color: Color.yellow.opacity(0.8)
//            ),
//            CategoryItem(
//                id: 5,
//                name: "Outdoor",
//                iconName: "leaf.fill",
//                color: Color.green.opacity(0.8)
//            ),
//            CategoryItem(
//                id: 6,
//                name: "Electronics",
//                iconName: "tv.and.hifispeaker.fill",
//                color: Color.purple.opacity(0.7)
//            )
//        ]
//        print("Initialized \(categories.count) local categories.")
//    }
//
//
//    // MARK: - Data Fetching from Firebase
//    func fetchItemsFromFirebase() {
//        guard !categories.isEmpty else {
//            print(
//                "Error: Local categories not initialized before fetching items."
//            )
//            self.isLoadingItems = false
//            self.allFetchedItems = []
//            self.applyFilters()
//            return
//        }
//
//        isLoadingItems = true
//        errorMessage = nil
//        
//        if let handle = self.itemsListenerHandle {
//            self.dbRef.child("items").removeObserver(withHandle: handle)
//        }
//        
//        itemsListenerHandle = dbRef
//            .child("items").observe(
//                .value,
//                with: { [weak self] (
//                    snapshot: DataSnapshot
//                ) -> Void in
//                    guard let self = self else { return }
//                    print("Firebase: Items snapshot received")
//
//                    var fetchedItems: [DisplayItem] = []
//                    if let value = snapshot.value as? [String: Any] {
//                        for (itemFirebaseKey, itemData) in value {
//                            if let itemDict = itemData as? [String: Any] {
//                                guard let name = itemDict["name"] as? String,
//                                      let imageName = itemDict["imageName"] as? String,
//                                      let rentalPrice = itemDict["rentalPrice"] as? String,
//                                      let fbCategoryId = itemDict["categoryId"] as? Int
//                                else {
//                                    print(
//                                        "Warning: Missing or invalid field(s) for item with Firebase key: \(itemFirebaseKey). Data: \(itemDict)"
//                                    )
//                                    continue
//                                }
//
//                                if self.categories
//                                    .contains(
//                                        where: { $0.id == fbCategoryId
//                                        }) {
//                                    fetchedItems
//                                        .append(DisplayItem(id: itemFirebaseKey,
//                                                            name: name,
//                                                            imageName: imageName,
//                                                            rentalPrice: rentalPrice,
//                                                            categoryId: fbCategoryId
//                                                           ))
//                                } else {
//                                    print(
//                                        "Warning: Item '\(name)' (ID: \(itemFirebaseKey)) has an invalid or unmatched categoryId: \(fbCategoryId). Skipping or assigning default."
//                                    )
//                                }
//                            } else {
//                                print(
//                                    "Warning: Could not parse item data for ID: \(itemFirebaseKey)"
//                                )
//                            }
//                        }
//                    } else if !snapshot.exists() {
//                        print("Firebase: No items found at 'items' path.")
//                    } else {
//                        print(
//                            "Error: Items snapshot value is not in the expected format or is null."
//                        )
//                    }
//            
//                    DispatchQueue.main.async {
//                        self.isLoadingItems = false
//                        self.allFetchedItems = fetchedItems
//                        print(
//                            "Fetched and processed \(fetchedItems.count) items from Firebase."
//                        )
//                        self.applyFilters()
//                    }
//                },
//                withCancel: { [weak self] error in
//                    guard let self = self else { return }
//                    DispatchQueue.main.async {
//                        self.isLoadingItems = false
//                        self.errorMessage = "Error fetching items: \(error.localizedDescription)"
//                        print(self.errorMessage!)
//                    }
//                })
//    }
//
//    // MARK: - Filtering Logic
//    func applyFilters() {
//        var filteredItems = self.allFetchedItems
//
//        if let categoryId = self.selectedCategoryId {
//            filteredItems = filteredItems
//                .filter { $0.categoryId == categoryId }
//        }
//
//        if self.isSearchActive && !self.searchText.isEmpty {
//            let lowercasedSearchText = self.searchText.lowercased()
//            filteredItems = filteredItems.filter { item in
//                item.name.lowercased().contains(lowercasedSearchText)
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.displayedNearYouItems = filteredItems
//            if filteredItems.isEmpty && (
//                self.isSearchActive || self.selectedCategoryId != nil
//            ) {
//                print("No items displayed for current filters.")
//            } else if filteredItems.isEmpty && !self.isLoadingItems {
//                print(
//                    "No items to display (and not currently loading)."
//                )
//            }
//        }
//    }
//
//    // MARK: - Search Actions
//    func performSearch() {
//        if searchText.isEmpty && selectedCategoryId == nil {
//            clearSearch(clearCategoryAlso: false)
//            return
//        }
//        isSearchActive = !searchText.isEmpty
//        applyFilters()
//    }
//    
//    func clearSearch(
//        clearCategoryAlso: Bool = false
//    ) {
//        searchText = ""
//        isSearchActive = false
//        if clearCategoryAlso {
//            clearCategoryFilter(
//                applyFilterAfter: false
//            )
//        }
//        applyFilters()
//        print("Search cleared.")
//    }
//
//    // MARK: - Category Actions
//    func selectCategory(
//        _ category: CategoryItem
//    ) {
//        guard categories
//            .contains(where: { $0.id == category.id }) else {
//            print(
//                "Error: Attempted to select a category not in the local list."
//            )
//            return
//        }
//        
//        if selectedCategoryId == category.id {
//            clearCategoryFilter()
//        } else {
//            selectedCategoryId = category.id
//            selectedCategoryName = category.name
//            applyFilters()
//        }
//    }
//
//    func clearCategoryFilter(
//        applyFilterAfter: Bool = true
//    ) {
//        selectedCategoryId = nil
//        selectedCategoryName = nil
//        if applyFilterAfter {
//            applyFilters()
//        }
//        print("Category filter cleared.")
//    }
//    
//    // MARK: - Combined Filter Actions (Remains the same)
//    func clearAllFilters() {
//        searchText = ""
//        isSearchActive = false
//        selectedCategoryId = nil
//        selectedCategoryName = nil
//        applyFilters()
//        print("All filters cleared.")
//    }
//
//    // MARK: - UI Helper Methods (Remains the same)
//    func getActiveFilterName() -> String? {
//        if let categoryName = selectedCategoryName {
//            if isSearchActive && !searchText.isEmpty {
//                return "\(categoryName) & \"\(searchText)\""
//            }
//            return categoryName
//        } else if isSearchActive && !searchText.isEmpty {
//            return "\"\(searchText)\""
//        }
//        return nil
//    }
//
//    func isAnyFilterActive() -> Bool {
//        return selectedCategoryId != nil || (
//            isSearchActive && !searchText.isEmpty
//        )
//    }
//    
//    func calculateOverlapHeight() -> CGFloat {
//        return 40
//    }
//
//    // MARK: - Adding Data to Firebase
//    func addItemToFirebase(
//        name: String,
//        localCategory: CategoryItem,
//        price: String,
//        ownerUid: String,
//        imageName: String = "SpareTrousers"
//    ) {
//        guard categories
//            .contains(where: { $0.id == localCategory.id }) else {
//            self.errorMessage = "Invalid category provided for new item."
//            print(self.errorMessage!)
//            return
//        }
//
//        guard let newItemFirebaseId = dbRef.child("items").childByAutoId().key else {
//            self.errorMessage = "Could not generate item ID."
//            return
//        }
//        
//        let itemData: [String: Any] = [
//            "name": name,
//            "description": "A fantastic item available for rent!",
//            "imageName": imageName,
//            "rentalPrice": price,
//            "categoryId": localCategory.id,
//            "ownerUid": ownerUid,
//            "isAvailable": true,
//            "dateListed": ISO8601DateFormatter()
//                .string(from: Date())
//        ]
//        
//        dbRef
//            .child("items")
//            .child(newItemFirebaseId)
//            .setValue(itemData) {
//                [weak self] error,
//                ref in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        self?.errorMessage = "Error adding item: \(error.localizedDescription)"
//                        print(
//                            self!.errorMessage!
//                        )
//                    } else {
//                        print(
//                            "Item '\(name)' added successfully to Firebase with ID: \(newItemFirebaseId)"
//                        )
//                    }
//                }
//            }
//    }
//}

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearchActive: Bool = false
    @Published var categories: [CategoryItem] = []
    @Published var selectedCategoryId: Int? = nil
    @Published var selectedCategoryName: String? = nil
    @Published var displayedNearYouItems: [DisplayItem] = []
    @Published var selectedTab: Tab = .home
    @Published var isLoadingItems: Bool = false
    @Published var errorMessage: String? = nil

    private var allFetchedItems: [DisplayItem] = []
    private var dbRef: DatabaseReference!
    private var itemsListenerHandle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()

    init() {
        dbRef = Database.database().reference()
        initializeLocalCategories()
        fetchItemsFromFirebase()
    }

    deinit {
        if let handle = itemsListenerHandle {
            dbRef.child("items").removeObserver(withHandle: handle)
        }
        print("HomeViewModel deinitialized and Firebase item listener removed.")
    }
    
    func initializeLocalCategories() {
        self.categories = [
            CategoryItem(id: 1, name: "Fashion", iconName: "tshirt.fill", color: Color.appBlue.opacity(0.7)),
            CategoryItem(id: 2, name: "Cooking", iconName: "fork.knife.circle.fill", color: Color.appOrange.opacity(0.7)),
            CategoryItem(id: 3, name: "Tools", iconName: "wrench.and.screwdriver.fill", color: Color.appOffGray.opacity(0.7)),
            CategoryItem(id: 4, name: "Toys", iconName: "gamecontroller.fill", color: Color.yellow.opacity(0.8)),
            CategoryItem(id: 5, name: "Outdoor", iconName: "leaf.fill", color: Color.green.opacity(0.8)),
            CategoryItem(id: 6, name: "Electronics", iconName: "tv.and.hifispeaker.fill", color: Color.purple.opacity(0.7))
        ]
        print("Initialized \(categories.count) local categories.")
    }

    func fetchItemsFromFirebase() {
        guard !categories.isEmpty else {
            print("Error: Local categories not initialized before fetching items.")
            self.isLoadingItems = false
            self.allFetchedItems = []
            self.applyFilters()
            return
        }

        isLoadingItems = true
        errorMessage = nil
        
        if let handle = self.itemsListenerHandle {
            self.dbRef.child("items").removeObserver(withHandle: handle)
        }
        
        itemsListenerHandle = dbRef.child("items").observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            print("Firebase: Items snapshot received")

            var fetchedItems: [DisplayItem] = []
            if let value = snapshot.value as? [String: Any] {
                for (itemFirebaseKey, itemData) in value {
                    if let itemDict = itemData as? [String: Any] {
                        guard let name = itemDict["name"] as? String,
                              let imageName = itemDict["imageName"] as? String,
                              let rentalPrice = itemDict["rentalPrice"] as? String,
                              let fbCategoryId = itemDict["categoryId"] as? Int,
                              // Fetch description, provide a default if not present
                              let description = itemDict["description"] as? String else {
                            print("Warning: Missing or invalid field(s) for item with Firebase key: \(itemFirebaseKey). Data: \(itemDict)")
                            continue
                        }
                        
                        // Optionally fetch other fields like isAvailable and ownerUid
                        let isAvailable = itemDict["isAvailable"] as? Bool
                        let ownerUid = itemDict["ownerUid"] as? String

                        if self.categories.contains(where: { $0.id == fbCategoryId }) {
                            fetchedItems.append(DisplayItem(id: itemFirebaseKey,
                                                            name: name,
                                                            imageName: imageName,
                                                            rentalPrice: rentalPrice,
                                                            categoryId: fbCategoryId,
                                                            description: description, // Pass description
                                                            isAvailable: isAvailable,
                                                            ownerUid: ownerUid
                                                           ))
                        } else {
                            print("Warning: Item '\(name)' (ID: \(itemFirebaseKey)) has an invalid or unmatched categoryId: \(fbCategoryId). Skipping.")
                        }
                    } else {
                        print("Warning: Could not parse item data for ID: \(itemFirebaseKey)")
                    }
                }
            } else if !snapshot.exists() {
                print("Firebase: No items found at 'items' path.")
            } else {
                print("Error: Items snapshot value is not in the expected format or is null.")
            }
    
            DispatchQueue.main.async {
                self.isLoadingItems = false
                self.allFetchedItems = fetchedItems
                print("Fetched and processed \(fetchedItems.count) items from Firebase.")
                self.applyFilters()
            }
        }, withCancel: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingItems = false
                self.errorMessage = "Error fetching items: \(error.localizedDescription)"
                print(self.errorMessage!)
            }
        })
    }

    func applyFilters() {
        var filteredItems = self.allFetchedItems
        if let categoryId = self.selectedCategoryId {
            filteredItems = filteredItems.filter { $0.categoryId == categoryId }
        }
        if self.isSearchActive && !self.searchText.isEmpty {
            let lowercasedSearchText = self.searchText.lowercased()
            filteredItems = filteredItems.filter { item in
                item.name.lowercased().contains(lowercasedSearchText)
            }
        }
        DispatchQueue.main.async {
            self.displayedNearYouItems = filteredItems
            if filteredItems.isEmpty && (self.isSearchActive || self.selectedCategoryId != nil) {
                print("No items displayed for current filters (Search: '\(self.searchText)', CategoryID: \(self.selectedCategoryId ?? -1)).")
            } else if filteredItems.isEmpty && !self.isLoadingItems {
                print("No items to display (and not currently loading).")
            }
        }
    }

    func performSearch() {
        if searchText.isEmpty && selectedCategoryId == nil {
            clearSearch(clearCategoryAlso: false); return
        }
        isSearchActive = !searchText.isEmpty; applyFilters()
    }
    
    func clearSearch(clearCategoryAlso: Bool = false) {
        searchText = ""; isSearchActive = false
        if clearCategoryAlso { clearCategoryFilter(applyFilterAfter: false) }
        applyFilters(); print("Search cleared.")
    }

    func selectCategory(_ category: CategoryItem) {
        guard categories.contains(where: { $0.id == category.id }) else {
            print("Error: Attempted to select a category not in the local list."); return
        }
        if selectedCategoryId == category.id { clearCategoryFilter() }
        else { selectedCategoryId = category.id; selectedCategoryName = category.name; applyFilters() }
    }

    func clearCategoryFilter(applyFilterAfter: Bool = true) {
        selectedCategoryId = nil; selectedCategoryName = nil
        if applyFilterAfter { applyFilters() }
        print("Category filter cleared.")
    }
    
    func clearAllFilters() {
        searchText = ""; isSearchActive = false; selectedCategoryId = nil; selectedCategoryName = nil
        applyFilters(); print("All filters cleared.")
    }

    func getActiveFilterName() -> String? {
        if let categoryName = selectedCategoryName {
            return isSearchActive && !searchText.isEmpty ? "\(categoryName) & \"\(searchText)\"" : categoryName
        }
        return isSearchActive && !searchText.isEmpty ? "\"\(searchText)\"" : nil
    }

    func isAnyFilterActive() -> Bool { selectedCategoryId != nil || (isSearchActive && !searchText.isEmpty) }
    func calculateOverlapHeight() -> CGFloat { 40 }

    func addItemToFirebase(name: String, localCategory: CategoryItem, price: String, ownerUid: String, imageName: String = "SpareTrousers") {
        guard categories.contains(where: { $0.id == localCategory.id }) else {
            self.errorMessage = "Invalid category provided for new item."; print(self.errorMessage!); return
        }
        guard let newItemFirebaseId = dbRef.child("items").childByAutoId().key else {
            self.errorMessage = "Could not generate item ID."; print(self.errorMessage ?? "Error: Could not generate item ID"); return
        }
        let itemData: [String: Any] = [
            "name": name, "description": "A fantastic item available for rent!", "imageName": imageName,
            "rentalPrice": price, "categoryId": localCategory.id, "ownerUid": ownerUid,
            "isAvailable": true, "dateListed": ISO8601DateFormatter().string(from: Date())
        ]
        dbRef.child("items").child(newItemFirebaseId).setValue(itemData) { [weak self] error, ref in
            DispatchQueue.main.async {
                if let error = error { self?.errorMessage = "Error adding item: \(error.localizedDescription)"; print(self!.errorMessage!) }
                else { print("Item '\(name)' added successfully to Firebase with ID: \(newItemFirebaseId)") }
            }
        }
    }
}
