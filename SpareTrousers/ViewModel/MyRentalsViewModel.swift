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
import FirebaseDatabase

class MyRentalViewModel: ObservableObject {
    @Published var myLendingItems: [DisplayItem] = []
    @Published var myBorrowedEntries: [(item: DisplayItem, transaction: Transaction, lenderDisplayName: String?)] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var homeViewModel: HomeViewModel
    private var authViewModel: AuthViewModel
    private var dbRef: DatabaseReference!
    private var transactionsListenerHandle: DatabaseHandle?
    private var cancellables = Set<AnyCancellable>()
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    init(homeViewModel: HomeViewModel, authViewModel: AuthViewModel) {
        self.homeViewModel = homeViewModel
        self.authViewModel = authViewModel
        self.dbRef = Database.database().reference()
        
        homeViewModel.$allFetchedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMyLendingItems()
                self?.processFetchedTransactions(
                    self?.lastFetchedTransactions ?? []
                )
            }
            .store(in: &cancellables)
                
        fetchTransactions()
    }
    
    deinit {
        if let handle = transactionsListenerHandle {
            dbRef.child("transactions").removeObserver(withHandle: handle)
        }
        cancellables.forEach { $0.cancel() }
        print(
            "MyRentalViewModel deinitialized and Firebase transaction listener removed."
        )
    }
    
    private var lastFetchedTransactions: [Transaction] = []
    
    private func fetchTransactions() {
        guard currentUserID != nil else {
            self.myLendingItems = []
            self.myBorrowedEntries = []
            print("MyRentalViewModel: User not logged in. Clearing data.")
            return
        }

        isLoading = true
        errorMessage = nil

        if let handle = self.transactionsListenerHandle {
            self.dbRef.child("transactions").removeObserver(withHandle: handle)
        }

        transactionsListenerHandle = dbRef
            .child("transactions")
            .observe(
.value,
 with: { [weak self] snapshot in
                guard let self = self else { return }
                print("MyRentalViewModel: Transactions snapshot received.")
                var parsedTransactions: [Transaction] = []
                if let value = snapshot.value as? [String: Any] {
                    for (transactionId, transData) in value {
                        if let transDict = transData as? [String: Any] {
                            guard let transactionDate = transDict["transactionDate"] as? String,
                                  let startTime = transDict["startTime"] as? String,
                                  let endTime = transDict["endTime"] as? String,
                                  let relatedItemId = transDict["relatedItemId"] as? String,
                                  let ownerId = transDict["ownerId"] as? String,
                                  let borrowerId = transDict["borrowerId"] as? String,
                                  let requestStatus = transDict["requestStatus"] as? String else {
                                print(
                                    "Warning: Missing or invalid field(s) for transaction with ID: \(transactionId). Data: \(transDict)"
                                )
                                continue
                            }
                            let transaction = Transaction(id: transactionId,
                                                          transactionDate: transactionDate,
                                                          startTime: startTime,
                                                          endTime: endTime,
                                                          relatedItemId: relatedItemId,
                                                          ownerId: ownerId,
                                                          borrowerId: borrowerId,
                                                          requestStatus: requestStatus)
                            parsedTransactions.append(transaction)
                        }
                    }
                }
                
     self.lastFetchedTransactions = parsedTransactions
     self.processFetchedTransactions(parsedTransactions)

 },
withCancel: { [weak self] error in
    guard let self = self else { return }
    DispatchQueue.main.async {
        self.isLoading = false
        self.errorMessage = "Error fetching transactions: \(error.localizedDescription)"
        print(self.errorMessage!)
    }
})
        updateMyLendingItems()
    }
    
    private func processFetchedTransactions(_ transactions: [Transaction]) {
        guard let uid = currentUserID else {
            self.myBorrowedEntries = []
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        DispatchQueue.main.async { self.isLoading = false }

        let activeBorrowedTransactions = transactions.filter {
            $0.borrowerId == uid && $0.requestStatus == "approved"
        }

        let allAvailableItems = self.homeViewModel.allFetchedItems
        
        var initialEntries: [(item: DisplayItem, transaction: Transaction, lenderDisplayName: String?)] = []
        for transaction in activeBorrowedTransactions {
            if let item = allAvailableItems.first(
                where: { $0.id == transaction.relatedItemId
                }) {
                initialEntries
                    .append(
                        (
                            item: item,
                            transaction: transaction,
                            lenderDisplayName: item.ownerUid
                        )
                    )
            }
        }
        initialEntries
            .sort { $0.transaction.startTime < $1.transaction.startTime }
                
        DispatchQueue.main.async {
            self.myBorrowedEntries = initialEntries
        }

        for i in 0..<initialEntries.count {
            let entry = initialEntries[i]
            guard let ownerUid = entry.item.ownerUid, !ownerUid.isEmpty else {
                continue
            }

            authViewModel.fetchUserDisplayName(uid: ownerUid)
                .receive(
                    on: DispatchQueue.main
                ) // Ensure UI updates on main thread
                .sink(
receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print(
                            "Error fetching display name for \(ownerUid): \(error)"
                        )
                    }
},
receiveValue: { [weak self] displayName in
    guard let self = self else { return }
    if i < self.myBorrowedEntries.count && self
        .myBorrowedEntries[i].item.id == entry.item.id {
        self.myBorrowedEntries[i].lenderDisplayName = displayName ?? ownerUid
    }
})
                .store(in: &cancellables)
        }
        print(
            "MyRentalViewModel: Updated myBorrowedEntries. Count: \(initialEntries.count). Name fetching initiated."
        )
    }
        
    
    func updateMyLendingItems() {
        guard let uid = currentUserID else {
            self.myLendingItems = []
            return
        }
        let filteredItems = self.homeViewModel.allFetchedItems.filter {
            $0.ownerUid == uid
        }
                
        DispatchQueue.main.async { // Ensure UI updates on main thread
            self.myLendingItems = filteredItems
        }
        print(
            "MyRentalViewModel: Updated myLendingItems. Count: \(filteredItems.count)"
        )
    }
    
    func filterAndDisplayMyLendingItems() {
        guard let uid = currentUserID else {
            self.myLendingItems = []
            print(
                "MyRentalViewModel: User not logged in, cannot filter lending items."
            )
            return
        }
        
        // Filter from all items provided by HomeViewModel
        let filteredItems = self.homeViewModel.allFetchedItems.filter { item in
            return item.ownerUid == uid && (item.isAvailable ?? false)
        }
        
        self.myLendingItems = filteredItems
        print(
            "MyRentalViewModel: Updated myLendingItems. Count: \(self.myLendingItems.count)"
        )
    }
    
    func updateMyBorrowedItems() {
        var _fetchedTransactions: [Transaction] = []
    }
}
