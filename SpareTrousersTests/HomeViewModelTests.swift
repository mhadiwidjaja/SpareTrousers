//
//  HomeViewModelTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import XCTest
import Combine
@testable import SpareTrousers

class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        viewModel = HomeViewModel()
        cancellables = []
    }
    
    override func tearDownWithError() throws {
            viewModel = nil
            cancellables = nil
            super.tearDown()
        }

    func testInitialization() {
            XCTAssertNotNil(viewModel.categories)
            XCTAssertFalse(viewModel.categories.isEmpty, "Categories should be initialized.")
            XCTAssertTrue(viewModel.displayedForYouItems.isEmpty, "displayedForYouItems should be empty initially.")
            XCTAssertEqual(viewModel.searchText, "")
            XCTAssertFalse(viewModel.isSearchActive)
            XCTAssertNil(viewModel.selectedCategoryId)
            XCTAssertNil(viewModel.selectedCategoryName)
        }

    func testCategorySelection() {
            guard let fashionCategory = viewModel.categories.first(where: { $0.name == "Fashion" }) else {
                XCTFail("Fashion category not found in default categories.")
                return
            }
            
            let expectation = XCTestExpectation(description: "Category selection updates displayed items")
            var updateCount = 0

            viewModel.$displayedForYouItems
                .dropFirst()
                .sink { _ in
                    updateCount += 1
                    if updateCount >= 2 {
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)
        
            viewModel.selectCategory(fashionCategory)
            XCTAssertEqual(viewModel.selectedCategoryId, fashionCategory.id)
            XCTAssertEqual(viewModel.selectedCategoryName, fashionCategory.name)
            XCTAssertTrue(viewModel.isAnyFilterActive())

            viewModel.selectCategory(fashionCategory)
            XCTAssertNil(viewModel.selectedCategoryId)
            XCTAssertNil(viewModel.selectedCategoryName)
            XCTAssertFalse(viewModel.isAnyFilterActive())
            
            wait(for: [expectation], timeout: 2.0)
        }

    func testSearchTextFiltering() {
        let item1 = DisplayItem(id: "1", name: "Blue Shirt", imageName: "", rentalPrice: "", categoryId: 1, description: "A nice blue shirt", isAvailable: true, ownerUid: "owner1")
                let item2 = DisplayItem(id: "2", name: "Red Trousers", imageName: "", rentalPrice: "", categoryId: 1, description: "Comfortable red trousers", isAvailable: true, ownerUid: "owner2")
                let item3 = DisplayItem(id: "3", name: "Blue Hat", imageName: "", rentalPrice: "", categoryId: 1, description: "A stylish blue hat", isAvailable: true, ownerUid: "owner3")
                let item4_unavailable = DisplayItem(id: "4", name: "Blue Jeans (Unavailable)", imageName: "", rentalPrice: "", categoryId: 1, description: "Unavailable blue jeans", isAvailable: false, ownerUid: "owner4")
        
        viewModel.allFetchedItems = [item1, item2, item3, item4_unavailable]
        
        viewModel.searchText = "Blue"
        viewModel.performSearch()

        let expectation = XCTestExpectation(description: "Filtering by search text completes")
                var observation: AnyCancellable?
                observation = viewModel.$displayedForYouItems
                    .dropFirst()
                    .sink { items in
                        if items.count == 2 {
                             XCTAssertTrue(items.contains(where: { $0.id == "1" }), "Blue Shirt should be present.")
                             XCTAssertTrue(items.contains(where: { $0.id == "3" }), "Blue Hat should be present.")
                             XCTAssertFalse(items.contains(where: { $0.id == "2" }), "Red Trousers should be filtered out.")
                             XCTAssertFalse(items.contains(where: { $0.id == "4" }), "Unavailable Blue Jeans should be filtered out.")
                             expectation.fulfill()
                             observation?.cancel() // Stop observing
                        } else if !self.viewModel.searchText.isEmpty && items.isEmpty && self.viewModel.allFetchedItems.contains(where: {$0.name.lowercased().contains("blue") && $0.isAvailable == true}) {
                        }
                    }
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
         }


        wait(for: [expectation], timeout: 2.0)
    }
    
    func testClearSearch() {
            viewModel.searchText = "test"
            viewModel.isSearchActive = true
            viewModel.selectCategory(viewModel.categories.first!)
            
            viewModel.clearSearch(clearCategoryAlso: false)
            XCTAssertEqual(viewModel.searchText, "")
            XCTAssertFalse(viewModel.isSearchActive)
            XCTAssertNotNil(viewModel.selectedCategoryId, "Category filter should not be cleared.")

            viewModel.searchText = "test"
            viewModel.isSearchActive = true
            viewModel.selectCategory(viewModel.categories.first!)
            
            viewModel.clearSearch(clearCategoryAlso: true)
            XCTAssertEqual(viewModel.searchText, "")
            XCTAssertFalse(viewModel.isSearchActive)
            XCTAssertNil(viewModel.selectedCategoryId, "Category filter should be cleared.")
            XCTAssertNil(viewModel.selectedCategoryName)
        }
    
    func testFilterExcludesUnavailableItems() {
            let itemAvailable = DisplayItem(id: "1", name: "Available Item", imageName: "img", rentalPrice: "10", categoryId: 1, description: "desc", isAvailable: true, ownerUid: "owner1")
            let itemUnavailable = DisplayItem(id: "2", name: "Unavailable Item", imageName: "img", rentalPrice: "10", categoryId: 1, description: "desc", isAvailable: false, ownerUid: "owner2")

            viewModel.allFetchedItems = [itemAvailable, itemUnavailable]
            viewModel.applyFilters()

            let expectation = XCTestExpectation(description: "Unavailable items are filtered out")
            
            var observation: AnyCancellable?
            observation = viewModel.$displayedForYouItems
                .dropFirst()
                .sink { displayedItems in
                    if displayedItems.count == 1 && displayedItems.first?.id == itemAvailable.id {
                        XCTAssertTrue(displayedItems.contains(where: { $0.id == itemAvailable.id }), "Available item should be included.")
                        XCTAssertFalse(displayedItems.contains(where: { $0.id == itemUnavailable.id }), "Unavailable item should be excluded.")
                        expectation.fulfill()
                        observation?.cancel()
                    }
                }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {}
            wait(for: [expectation], timeout: 2.0)
            observation?.cancel()
        }
    
    func testGetActiveFilterName() {
            XCTAssertNil(viewModel.getActiveFilterName())

            viewModel.searchText = "Tool"
            viewModel.isSearchActive = true
            XCTAssertEqual(viewModel.getActiveFilterName(), "\"Tool\"")

            guard let toolsCategory = viewModel.categories.first(where: {$0.name == "Tools"}) else {
                XCTFail("Tools category not found"); return
            }
            viewModel.selectCategory(toolsCategory)
            XCTAssertEqual(viewModel.getActiveFilterName(), "\(toolsCategory.name) & \"Tool\"")
            
            viewModel.searchText = ""
            viewModel.isSearchActive = false
            XCTAssertEqual(viewModel.getActiveFilterName(), toolsCategory.name)
            
            viewModel.clearAllFilters()
            XCTAssertNil(viewModel.getActiveFilterName())
        }
}
