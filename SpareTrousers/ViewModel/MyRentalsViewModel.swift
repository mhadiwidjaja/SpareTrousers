//
//  MyRentalsViewModel.swift
//  SpareTrousers
//
//  Created by student on 03/06/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class MyRentalViewModel: ObservableObject {
    @Published var myLendingItems: [DisplayItem] = []
    
    private var homeViewModel: HomeViewModel // Dependency to access allFetchedItems
    private var cancellables = Set<AnyCancellable>()
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        observeHomeViewModelItems()
    }

    private func observeHomeViewModelItems() {
        homeViewModel.$allFetchedItems // Assuming allFetchedItems is @Published in HomeViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in // We get a signal that allFetchedItems has changed
                self?.filterAndDisplayMyLendingItems()
            }
            .store(in: &cancellables)
        
        // Initial filter in case allFetchedItems is already populated
        filterAndDisplayMyLendingItems()
    }

    /**
     Filters all fetched items to find those owned by the current user
     and updates the `myLendingItems` published property.
     This function is called automatically when `allFetchedItems` in `HomeViewModel` changes.
     */
    func filterAndDisplayMyLendingItems() {
        guard let uid = currentUserID else {
            self.myLendingItems = []
            print("MyRentalViewModel: User not logged in, cannot filter lending items.")
            return
        }
        
        // Filter from all items provided by HomeViewModel
        let filteredItems = self.homeViewModel.allFetchedItems.filter { item in
            return item.ownerUid == uid && (item.isAvailable ?? false)
        }
        
        self.myLendingItems = filteredItems
        print("MyRentalViewModel: Updated myLendingItems. Count: \(self.myLendingItems.count)")
    }
}
