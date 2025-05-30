//
//  HomeViewModel.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//

import SwiftUI
import Combine
import FirebaseAuth // For user session, if needed for ownerUid later
import FirebaseDatabase // For Realtime Database
// import FirebaseDatabaseSwift // Only if you decide to use Codable directly with RTDB extensions

class HomeViewModel: ObservableObject {
    // MARK: - Published Properties for UI State
    @Published var searchText: String = ""
    @Published var isSearchActive: Bool = false

    @Published var categories: [CategoryItem] = []
    @Published var selectedCategoryId: UUID? = nil
    @Published var selectedCategoryName: String? = nil // For UI display if needed

    @Published var displayedNearYouItems: [DisplayItem] = []
    
    @Published var selectedTab: Tab = .home // Assuming Tab enum is defined elsewhere
    @Published var isLoadingItems: Bool = false
    @Published var isLoadingCategories: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Private Properties
    private var allFetchedItems: [DisplayItem] = [] // Stores all items fetched from Firebase
    private var dbRef: DatabaseReference!
    private var itemsListenerHandle: DatabaseHandle?
    private var categoriesListenerHandle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        dbRef = Database.database().reference() // Initialize database reference
        
        // Start listening for data changes
        // Note: fetchCategoriesFromFirebase() will subsequently call fetchItemsFromFirebase()
        // to ensure categories are available for item mapping.
        fetchCategoriesFromFirebase()

        // You could also use Combine to chain these fetches if dependencies are complex
        // or use async/await in a Task if targeting iOS 15+ for cleaner async code.
    }

    deinit {
        // Remove Firebase listeners when ViewModel is deallocated
        if let handle = itemsListenerHandle {
            dbRef.child("items").removeObserver(withHandle: handle)
        }
        if let handle = categoriesListenerHandle {
            dbRef.child("categories").removeObserver(withHandle: handle)
        }
        print("HomeViewModel deinitialized and Firebase listeners removed.")
    }

    // MARK: - Data Fetching from Firebase
    func fetchCategoriesFromFirebase() {
        isLoadingCategories = true
        errorMessage = nil
        
        categoriesListenerHandle = dbRef.child("categories").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            print("Firebase: Categories snapshot received")
            
            var fetchedCategories: [CategoryItem] = []
            if let value = snapshot.value as? [String: Any] {
                for (categoryIdString, catData) in value {
                    if let catDict = catData as? [String: Any],
                       let name = catDict["name"] as? String,
                       let iconName = catDict["iconName"] as? String,
                       let colorHex = catDict["colorHex"] as? String, // Assuming color stored as hex
                       let categoryUUID = UUID(uuidString: categoryIdString) {
                        
                        fetchedCategories.append(CategoryItem(id: categoryUUID,
                                                            name: name,
                                                            iconName: iconName,
                                                            color: Color(hex: colorHex))) // Use your Color(hex:) initializer
                    } else {
                        print("Warning: Could not parse category data for ID: \(categoryIdString)")
                    }
                }
            } else if !snapshot.exists() {
                print("Firebase: No categories found at 'categories' path.")
            } else {
                print("Error: Categories snapshot value is not in the expected format or is null.")
            }
            
            DispatchQueue.main.async {
                self.isLoadingCategories = false
                self.categories = fetchedCategories.sorted(by: { $0.name < $1.name }) // Sort for consistent display
                print("Fetched and processed \(fetchedCategories.count) categories from Firebase.")
                
                // Now that categories are fetched, fetch items (as items might depend on category data for mapping)
                // Remove previous item listener before adding a new one to prevent duplicates if this func is called again
                if let handle = self.itemsListenerHandle {
                    self.dbRef.child("items").removeObserver(withHandle: handle)
                }
                self.fetchItemsFromFirebase()
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingCategories = false
                self.errorMessage = "Error fetching categories: \(error.localizedDescription)"
                print(self.errorMessage!)
            }
        }
    }

    func fetchItemsFromFirebase() {
        guard !categories.isEmpty else {
            print("Attempted to fetch items before categories were loaded. Aborting item fetch.")
            // Optionally, you could set a flag to retry or handle this state.
            // For now, we assume categories will load, and then this is called.
            // If categories fetch fails, items won't be fetched by the current logic.
            self.isLoadingItems = false // Ensure loading state is reset
            self.allFetchedItems = []
            self.applyFilters() // Update UI with empty items
            return
        }

        isLoadingItems = true
        errorMessage = nil
        
        itemsListenerHandle = dbRef.child("items").observe(.value) { [weak self] snapshot,<#arg#>  in
            guard let self = self, !self.categories.isEmpty else {
                // If self is nil or categories haven't loaded (should be rare here due to call order)
                DispatchQueue.main.async {
                    self?.isLoadingItems = false
                }
                return
            }
            print("Firebase: Items snapshot received")

            var fetchedItems: [DisplayItem] = []
            if let value = snapshot.value as? [String: Any] {
                for (itemIdString, itemData) in value {
                    if let itemDict = itemData as? [String: Any],
                       let name = itemDict["name"] as? String,
                       let imageName = itemDict["imageName"] as? String, // Or imageUrl
                       let rentalPrice = itemDict["rentalPrice"] as? String,
                       let categoryIdString = itemDict["categoryId"] as? String, // Stored as String in Firebase
                       let itemUUID = UUID(uuidString: itemIdString) { // Use Firebase key as ID

                        // Find the matching CategoryItem struct using the categoryIdString
                        if let matchedCategoryUUID = UUID(uuidString: categoryIdString),
                           self.categories.contains(where: { $0.id == matchedCategoryUUID }) {
                            fetchedItems.append(DisplayItem(id: itemUUID,
                                                          name: name,
                                                          imageName: imageName,
                                                          rentalPrice: rentalPrice,
                                                          categoryId: matchedCategoryUUID))
                        } else {
                            print("Warning: Item '\(name)' (ID: \(itemIdString)) has an invalid or unmatched categoryId: \(categoryIdString). Skipping item or assigning default.")
                            // Optionally assign a default category or skip the item
                        }
                    } else {
                        print("Warning: Could not parse item data for ID: \(itemIdString)")
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
                self.applyFilters() // Apply filters after new data is loaded
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingItems = false
                self.errorMessage = "Error fetching items: \(error.localizedDescription)"
                print(self.errorMessage!)
            }
        }
    }

    // MARK: - Filtering Logic
    func applyFilters() {
        // This can be computationally intensive for large datasets on main thread.
        // Consider backgrounding if performance issues arise with many items.
        // For now, keeping it synchronous after async Firebase fetches.
        
        var filteredItems = self.allFetchedItems

        // 1. Apply category filter
        if let categoryId = self.selectedCategoryId {
            filteredItems = filteredItems.filter { $0.categoryId == categoryId }
        }

        // 2. Apply search filter (on the result of category filter or all items)
        if self.isSearchActive && !self.searchText.isEmpty {
            let lowercasedSearchText = self.searchText.lowercased()
            filteredItems = filteredItems.filter { item in
                item.name.lowercased().contains(lowercasedSearchText)
            }
        }
        
        DispatchQueue.main.async { // Ensure UI updates on main thread
            self.displayedNearYouItems = filteredItems
            if filteredItems.isEmpty && (self.isSearchActive || self.selectedCategoryId != nil) {
                print("No items displayed for current filters.")
            } else if filteredItems.isEmpty && !self.isLoadingItems && !self.isLoadingCategories {
                 print("No items to display (and not currently loading).")
            }
        }
    }

    // MARK: - Search Actions
    func performSearch() {
        if searchText.isEmpty && selectedCategoryId == nil {
            clearSearch(clearCategoryAlso: false) // Only clear search state, not category if search text becomes empty
            return
        }
        
        if !searchText.isEmpty {
            isSearchActive = true
        } else {
            // If search text is empty, but a category might be selected,
            // we don't want to deactivate search in a way that hides the category filter status.
            // isSearchActive strictly refers to the text search.
            isSearchActive = false
        }
        applyFilters()
    }
    
    func clearSearch(clearCategoryAlso: Bool = false) { // Default to not clearing category from search clear
        searchText = ""
        isSearchActive = false
        if clearCategoryAlso {
           clearCategoryFilter(applyFilterAfter: false) // Avoid double filter if clearing both
        }
        applyFilters() // Always apply filters after clearing search
        print("Search cleared.")
    }

    // MARK: - Category Actions
    func selectCategory(_ category: CategoryItem) {
        if selectedCategoryId == category.id {
            // If the same category is tapped again, deselect it
            clearCategoryFilter() // This will call applyFilters
        } else {
            selectedCategoryId = category.id
            selectedCategoryName = category.name
            applyFilters()
        }
    }

    func clearCategoryFilter(applyFilterAfter: Bool = true) {
        selectedCategoryId = nil
        selectedCategoryName = nil
        if applyFilterAfter {
            applyFilters()
        }
        print("Category filter cleared.")
    }
    
    // MARK: - Combined Filter Actions
    func clearAllFilters() {
        searchText = ""
        isSearchActive = false
        selectedCategoryId = nil
        selectedCategoryName = nil
        applyFilters()
        print("All filters cleared.")
    }

    // MARK: - UI Helper Methods
    func getActiveFilterName() -> String? {
        if let categoryName = selectedCategoryName {
            if isSearchActive && !searchText.isEmpty {
                return "\(categoryName) & \"\(searchText)\"" // Both active
            }
            return categoryName // Only category
        } else if isSearchActive && !searchText.isEmpty {
            return "\"\(searchText)\"" // Only search
        }
        return nil // No filters active
    }

    func isAnyFilterActive() -> Bool {
        return selectedCategoryId != nil || (isSearchActive && !searchText.isEmpty)
    }
    
    func calculateOverlapHeight() -> CGFloat {
        // This value is for the visual overlap in HomeView.
        // Adjust based on your TopNavBar's actual height and desired gap.
        return 40
    }

    // MARK: - Example: Adding Data to Firebase (For future use)
    // Ensure ownerUid comes from AuthViewModel.userSession.uid
    func addItemToFirebase(name: String, categoryId: UUID, price: String, ownerUid: String, imageName: String = "SpareTrousers") {
        guard let newItemFirebaseId = dbRef.child("items").childByAutoId().key else {
            self.errorMessage = "Could not generate item ID."
            return
        }
        
        let itemData: [String: Any] = [
            "name": name,
            "description": "A fantastic item available for rent!", // Add a proper description field
            "imageName": imageName, // This would typically be a URL from Firebase Storage
            "rentalPrice": price,
            "categoryId": categoryId.uuidString, // Store category ID as string
            "ownerUid": ownerUid,
            "isAvailable": true,
            "dateListed": ISO8601DateFormatter().string(from: Date())
            // Add other relevant fields like condition, location, etc.
        ]
        
        dbRef.child("items").child(newItemFirebaseId).setValue(itemData) { [weak self] error, ref in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error adding item: \(error.localizedDescription)"
                    print(self!.errorMessage!)
                } else {
                    print("Item '\(name)' added successfully to Firebase with ID: \(newItemFirebaseId)")
                    // Real-time listener will update the UI, no need to manually re-fetch or add to local array.
                }
            }
        }
    }
    
    func addCategoryToFirebase(name: String, iconName: String, colorHex: String) {
        let categoryUUID = UUID() // Generate a new UUID for the category
        let categoryIdString = categoryUUID.uuidString
        
        let categoryData: [String: Any] = [
            "name": name,
            "iconName": iconName,
            "colorHex": colorHex // Store color as hex string
            // Add other fields if necessary
        ]
        
        dbRef.child("categories").child(categoryIdString).setValue(categoryData) { [weak self] error, ref in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error adding category: \(error.localizedDescription)"
                    print(self!.errorMessage!)
                } else {
                    print("Category '\(name)' added successfully to Firebase with ID: \(categoryIdString)")
                }
            }
        }
    }
}
