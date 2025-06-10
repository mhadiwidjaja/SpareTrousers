//
//  InboxViewModel.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI
import Combine
import FirebaseDatabase
import FirebaseAuth

class InboxViewModel: ObservableObject {
    @Published var inboxMessages: [InboxMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var relevantTransactions: [Transaction] = []
    private var dbRef: DatabaseReference!
    private var messagesListenerHandle: DatabaseHandle?
    private var transactionsListenerHandle_owner: DatabaseHandle?
    private var transactionsListenerHandle_borrower: DatabaseHandle?
    private var currentUserId: String?
    private var authViewModel_UserDisplayName: String?
    private var authViewModel_UserEmail: String?
    private var itemNameCache: [String: String] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    private var humanReadableDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium; formatter.timeStyle = .short
        return formatter
    }
    
    let MSG_TYPE_LOCAL_BORROWER_RETURN_PROMPT = "local_borrower_return_prompt"
    let MSG_TYPE_LENDER_CONFIRM_RECEIPT_PROMPT = "lender_confirm_receipt_prompt"
    let MSG_TYPE_ITEM_RETURN_COMPLETED = "item_return_completed"
    let MSG_TYPE_LENDER_DISPUTED_RETURN = "lender_disputed_return"
    let MSG_TYPE_RETURN_DISPUTE_LOGGED_FOR_LENDER = "return_dispute_logged_for_lender"
    let MSG_TYPE_REQUEST_RECEIVED = "request_received"
    let MSG_TYPE_REQUEST_APPROVED = "request_approved"
    let MSG_TYPE_REQUEST_DECLINED = "request_declined"
    
    
    init() {
        dbRef = Database.database().reference()
    }
    
    func setupListeners(forUser uid: String, userDisplayName: String?, userEmail: String?) {
        if currentUserId == uid && messagesListenerHandle != nil { return }
        unsubscribeAll()
        currentUserId = uid
        authViewModel_UserDisplayName = userDisplayName
        authViewModel_UserEmail = userEmail
        
        subscribeToInboxMessages(forUser: uid)
        subscribeToUserTransactions(forUser: uid)
    }
    
    // Subscribes to real-time updates for messages in the current user's inbox path in Firebase.
    // Updates `inboxMessages` when new messages arrive or existing ones change.
    private func subscribeToInboxMessages(forUser uid: String) {
        isLoading = true; errorMessage = nil
        let userMessagesRef = dbRef.child("inbox_messages").child(uid)
        messagesListenerHandle = userMessagesRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            var fetchedFirebaseMessages: [InboxMessage] = []
            if snapshot.exists(), let children = snapshot.children.allObjects as? [DataSnapshot] {
                children.forEach { childSnapshot in
                    if let messageData = childSnapshot.value as? [String: Any],
                       let message = InboxMessage(id: childSnapshot.key, dictionary: messageData) {
                        fetchedFirebaseMessages.append(message)
                    }
                }
            }
            self.inboxMessages = fetchedFirebaseMessages
            self.generateAndMergeLocalReminders()
        }) { [weak self] error in self?.handleError("fetching inbox messages", error) }
    }
    
    // Subscribes to transactions where the user is either the owner or the borrower.
    private func subscribeToUserTransactions(forUser uid: String) {
        let ownerQuery = dbRef.child("transactions").queryOrdered(byChild: "ownerId").queryEqual(toValue: uid)
        transactionsListenerHandle_owner = ownerQuery.observe(.value) { [weak self] snapshot in
            self?.processTransactionSnapshot(snapshot, forUser: uid, asRole: .owner)
        }
        let borrowerQuery = dbRef.child("transactions").queryOrdered(byChild: "borrowerId").queryEqual(toValue: uid)
        transactionsListenerHandle_borrower = borrowerQuery.observe(.value) { [weak self] snapshot in
            self?.processTransactionSnapshot(snapshot, forUser: uid, asRole: .borrower)
        }
    }
    
    private enum UserRoleInTransaction { case owner, borrower }
    
    // Processes transaction snapshots for both owner and borrower roles
    private func processTransactionSnapshot(_ snapshot: DataSnapshot, forUser uid: String, asRole: UserRoleInTransaction) {
        var newTransactions: [Transaction] = []
        if snapshot.exists(), let children = snapshot.children.allObjects as? [DataSnapshot] {
            children.forEach { childSnapshot in
                if let transData = childSnapshot.value as? [String: Any],
                   let transaction = parseTransaction(from: transData, id: childSnapshot.key) {
                    // Filter for statuses relevant to generating reminders or actions
                    let relevantStatuses = ["approved", "active_rental", "pending_lender_confirmation"]
                    if relevantStatuses.contains(transaction.requestStatus) {
                        newTransactions.append(transaction)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            // Merge logic for relevantTransactions
            var currentTransactionIds = Set(self.relevantTransactions.map { $0.id })
            newTransactions.forEach { trans in
                if !currentTransactionIds.contains(trans.id) {
                    self.relevantTransactions.append(trans); currentTransactionIds.insert(trans.id)
                } else if let index = self.relevantTransactions.firstIndex(where: { $0.id == trans.id }) {
                    self.relevantTransactions[index] = trans
                }
            }
            self.relevantTransactions.removeAll { transaction in
                let relevantStatuses = ["approved", "active_rental", "pending_lender_confirmation"]
                return !relevantStatuses.contains(transaction.requestStatus) || (transaction.ownerId != uid && transaction.borrowerId != uid)
            }
            self.generateAndMergeLocalReminders()
        }
    }
    
    private func parseTransaction(from data: [String: Any], id: String) -> Transaction? {
        guard let transactionDateStr = data["transactionDate"] as? String,
              let startTimeStr = data["startTime"] as? String,
              let endTimeStr = data["endTime"] as? String,
              let relatedItemId = data["relatedItemId"] as? String,
              let ownerId = data["ownerId"] as? String,
              let borrowerId = data["borrowerId"] as? String,
              let requestStatus = data["requestStatus"] as? String else {
            print("InboxViewModel: Failed to parse transaction \(id)")
            return nil
        }
        return Transaction(id: id, transactionDate: transactionDateStr, startTime: startTimeStr, endTime: endTimeStr, relatedItemId: relatedItemId, ownerId: ownerId, borrowerId: borrowerId, requestStatus: requestStatus)
    }
    
    // Generates local, non-persistent reminder messages based on `relevantTransactions`.
//    private func generateAndMergeLocalReminders() {
//        guard let currentUid = self.currentUserId else { return }
//        var localReminders: [InboxMessage] = []
//        let now = Date()
//        
//        for transaction in self.relevantTransactions {
//            guard let endTimeDate = isoDateFormatter.date(from: transaction.endTime) else { continue }
//            
//            if transaction.borrowerId == currentUid &&
//                (transaction.requestStatus == "approved" || transaction.requestStatus == "active_rental") &&
//                now >= endTimeDate {
//                let reminderId = "borrower_return_prompt_\(transaction.id)"
//                if !self.inboxMessages.contains(where: { $0.id == reminderId && $0.type.hasPrefix("local_") }) {
//                    localReminders.append(InboxMessage(
//                        id: reminderId,
//                        dateLine: "Have you returned '\(transaction.relatedItemId)'?",
//                        type: MSG_TYPE_LOCAL_BORROWER_RETURN_PROMPT,
//                        showsRejectButton: true,
//                        relatedTransactionId: transaction.id,
//                        timestamp: endTimeDate.timeIntervalSince1970 + 1,
//                        isRead: false, lenderName: "System", itemName: transaction.relatedItemId
//                    ))
//                }
//            }
//        }
//        DispatchQueue.main.async {
//            let firebaseMessages = self.inboxMessages.filter { !$0.type.hasPrefix("local_") }
//            self.inboxMessages = (firebaseMessages + localReminders).sorted(by: { $0.timestamp > $1.timestamp })
//        }
//    }
    private func generateAndMergeLocalReminders() {
        guard let currentUid = self.currentUserId, !relevantTransactions.isEmpty else {
            // If no relevant transactions, ensure no local reminders are present
            let firebaseMessages = self.inboxMessages.filter { !$0.type.hasPrefix("local_") }
            if firebaseMessages.count != self.inboxMessages.count {
                DispatchQueue.main.async { self.inboxMessages = firebaseMessages }
            }
            return
        }

        let now = Date()
        var reminderPublishers: [AnyPublisher<InboxMessage?, Never>] = []

        for transaction in self.relevantTransactions {
            guard let endTimeDate = isoDateFormatter.date(from: transaction.endTime) else { continue }

            if transaction.borrowerId == currentUid &&
               (transaction.requestStatus == "approved" || transaction.requestStatus == "active_rental") &&
               now >= endTimeDate {
                
                let reminderId = "borrower_return_prompt_\(transaction.id)"
                // Skip if this local reminder is already in the list
                if self.inboxMessages.contains(where: { $0.id == reminderId }) { continue }

                // Create a publisher that fetches the item name and then creates the message
                let publisher = fetchItemName(for: transaction.relatedItemId)
                    .map { itemName -> InboxMessage? in
                        return InboxMessage(
                            id: reminderId,
                            dateLine: "Have you returned '\(itemName)'?",
                            type: self.MSG_TYPE_LOCAL_BORROWER_RETURN_PROMPT,
                            showsRejectButton: true,
                            relatedTransactionId: transaction.id,
                            timestamp: endTimeDate.timeIntervalSince1970 + 1,
                            isRead: false,
                            lenderName: "System",
                            itemName: itemName // Use the fetched name
                        )
                    }
                    .replaceError(with: nil) // If fetching item name fails, produce nil
                    .eraseToAnyPublisher()
                
                reminderPublishers.append(publisher)
            }
        }

        guard !reminderPublishers.isEmpty else {
            // No new reminders to generate, but we still need to clean up old ones if any
            let firebaseMessages = self.inboxMessages.filter { !$0.type.hasPrefix("local_") }
            if firebaseMessages.count != self.inboxMessages.count {
                DispatchQueue.main.async { self.inboxMessages = firebaseMessages }
            }
            return
        }
        
        // Combine all reminder publishers
        Publishers.MergeMany(reminderPublishers)
            .compactMap { $0 } // Remove nil results (from fetch errors)
            .collect() // Wait for all publishers to complete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newLocalReminders in
                guard let self = self else { return }
                let firebaseMessages = self.inboxMessages.filter { !$0.type.hasPrefix("local_") }
                self.inboxMessages = (firebaseMessages + newLocalReminders).sorted(by: { $0.timestamp > $1.timestamp })
                print("InboxViewModel: Regenerated local reminders. Total messages: \(self.inboxMessages.count)")
            })
            .store(in: &cancellables) // Store the sink subscription
    }
    
    private func fetchItemName(for itemId: String) -> AnyPublisher<String, Error> {
        // Check cache first
        if let cachedName = itemNameCache[itemId] {
            return Just(cachedName)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Future<String, Error> { [weak self] promise in
            guard let self = self else { return }
            self.dbRef.child("items").child(itemId).child("name").observeSingleEvent(of: .value) { snapshot in
                if let itemName = snapshot.value as? String {
                    // Store in cache and return
                    self.itemNameCache[itemId] = itemName
                    promise(.success(itemName))
                } else {
                    promise(.failure(NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item name not found for ID: \(itemId)"])))
                }
            } withCancel: { error in
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Message Action Handlers
    // Handles the Borrower's return action, updating transaction status and notifying the Lender.
//    func handleBorrowerReturnedAction(message: InboxMessage, didReturn: Bool) {
//        guard let transactionId = message.relatedTransactionId,
//              let currentUid = self.currentUserId,
//              let transaction = relevantTransactions.first(where: { $0.id == transactionId }),
//              transaction.borrowerId == currentUid else {
//            print("Error: Cannot process borrower return action. Invalid context."); return
//        }
//        
//        if didReturn {
//            //  Update Transaction status to "pending_lender_confirmation"
//            dbRef.child("transactions").child(transactionId).child("requestStatus").setValue("pending_lender_confirmation") { [weak self] error, _ in
//                guard let self = self else { return }
//                if let error = error { self.handleError("updating transaction for borrower return", error); return }
//                
//                // Send InboxMessage to Owner
//                let ownerMessageId = UUID().uuidString
//                let borrowerName = self.authViewModel_UserDisplayName ?? self.authViewModel_UserEmail ?? "A user"
//                let ownerMessage = InboxMessage(
//                    id: ownerMessageId,
//                    dateLine: "\(borrowerName) states they have returned '\(message.itemName)'. Please confirm.",
//                    type: self.MSG_TYPE_LENDER_CONFIRM_RECEIPT_PROMPT,
//                    showsRejectButton: true,
//                    relatedTransactionId: transactionId,
//                    timestamp: Date().timeIntervalSince1970,
//                    isRead: false,
//                    lenderName: borrowerName,
//                    itemName: transaction.relatedItemId
//                )
//                self.sendMessage(ownerMessage, toUser: transaction.ownerId)
//                
//                self.markMessageAsRead(messageId: message.id)
//            }
//        } else {
//            print("Borrower indicated item not yet returned for transaction: \(transactionId)")
//            self.markMessageAsRead(messageId: message.id)
//        }
//    }
    
    func handleBorrowerReturnedAction(message: InboxMessage, didReturn: Bool) {
        guard let transactionId = message.relatedTransactionId,
              let currentUid = self.currentUserId,
              let transaction = relevantTransactions.first(where: { $0.id == transactionId }),
              transaction.borrowerId == currentUid else {
            print("Error: Cannot process borrower return action. Invalid context."); return
        }

        if didReturn {
            dbRef.child("transactions").child(transactionId).child("requestStatus").setValue("pending_lender_confirmation") { [weak self] error, _ in
                guard let self = self else { return }
                if let error = error { self.handleError("updating transaction for borrower return", error); return }

                let ownerMessageId = UUID().uuidString
                let borrowerName = self.authViewModel_UserDisplayName ?? self.authViewModel_UserEmail ?? "A user"
                let itemName = message.itemName ?? "your item" // Use the name from the message
                
                let ownerMessage = InboxMessage(
                    id: ownerMessageId,
                    dateLine: "\(borrowerName) states they have returned '\(itemName)'. Please confirm.",
                    type: self.MSG_TYPE_LENDER_CONFIRM_RECEIPT_PROMPT,
                    showsRejectButton: true,
                    relatedTransactionId: transactionId,
                    timestamp: Date().timeIntervalSince1970,
                    isRead: false,
                    lenderName: borrowerName,
                    itemName: itemName
                )
                self.sendMessage(ownerMessage, toUser: transaction.ownerId)
                self.markMessageAsRead(messageId: message.id)
            }
        } else {
            print("Borrower indicated item not yet returned for transaction: \(transactionId)")
            self.markMessageAsRead(messageId: message.id)
        }
    }
    
    // Handles the Lender's confirmation of receipt action, either confirming return or disputing it.
    func handleLenderConfirmReceiptAction(message: InboxMessage, didReceive: Bool) {
        guard let transactionId = message.relatedTransactionId,
              let currentUid = self.currentUserId,
              let transaction = relevantTransactions.first(where: { $0.id == transactionId }),
              transaction.ownerId == currentUid else {
            print("Error: Cannot process lender receipt action. Invalid context."); return
        }
        
        let transactionRef = dbRef.child("transactions").child(transactionId)
        let itemRef = dbRef.child("items").child(transaction.relatedItemId)
        
        if didReceive {
            // Update Transaction status to "completed"
            transactionRef.child("requestStatus").setValue("completed") { [weak self] error, _ in
                guard let self = self else { return }
                if let error = error { self.handleError("completing transaction", error); return }
                
                // Update Item availability to true
                itemRef.child("isAvailable").setValue(true) { error, _ in
                    if let error = error { self.handleError("updating item availability", error); /* Continue anyway */ }
                }
                
                // Send confirmation to Borrower
                let borrowerMessageId = UUID().uuidString
                let itemName = message.itemName ?? "your item" // Use the name from the message
                let borrowerMessage = InboxMessage(
                    id: borrowerMessageId,
                    dateLine: "Lender confirmed return of '\(itemName)'. Thank you!",
                    type: self.MSG_TYPE_ITEM_RETURN_COMPLETED,
                    showsRejectButton: false,
                    relatedTransactionId: transactionId,
                    timestamp: Date().timeIntervalSince1970,
                    isRead: false,
                    lenderName: "System",
                    itemName: transaction.relatedItemId
                )
                self.sendMessage(borrowerMessage, toUser: transaction.borrowerId)
                self.markMessageAsRead(messageId: message.id)
            }
        } else {
            // Update Transaction status to "disputed_return"
            transactionRef.child("requestStatus").setValue("disputed_return") { [weak self] error, _ in
                guard let self = self else { return }
                if let error = error { self.handleError("setting transaction to disputed", error); return }
                
                // Notify Borrower
                let borrowerMessageId = UUID().uuidString
                let itemName = message.itemName ?? "your item" // Use the name from the message
                let borrowerMessage = InboxMessage(
                    id: borrowerMessageId,
                    dateLine: "Lender reports '\(itemName)' not yet received. Please ensure return or contact lender.",
                    type: self.MSG_TYPE_LENDER_DISPUTED_RETURN,
                    showsRejectButton: false,
                    relatedTransactionId: transactionId,
                    timestamp: Date().timeIntervalSince1970,
                    isRead: false,
                    lenderName: "System",
                    itemName: transaction.relatedItemId
                )
                self.sendMessage(borrowerMessage, toUser: transaction.borrowerId)
                
                // Optionally, notify Lender that dispute is logged (or just update their UI)
                let lenderConfirmationId = UUID().uuidString
                let lenderConfirmationMessage = InboxMessage(
                    id: lenderConfirmationId,
                    dateLine: "You reported item '\(message.itemName)' not received. Borrower notified.",
                    type: self.MSG_TYPE_RETURN_DISPUTE_LOGGED_FOR_LENDER,
                    showsRejectButton: false,
                    relatedTransactionId: transactionId,
                    timestamp: Date().timeIntervalSince1970 + 1,
                    isRead: false,
                    lenderName: "System",
                    itemName: transaction.relatedItemId
                )
                self.sendMessage(lenderConfirmationMessage, toUser: transaction.ownerId)
                self.markMessageAsRead(messageId: message.id)
            }
        }
    }
    
    // MARK: - Utility & Existing Functions
    private func sendMessage(_ message: InboxMessage, toUser userId: String) {
        let messageRef = dbRef.child("inbox_messages").child(userId).child(message.id)
        do {
            let messageData = try JSONEncoder().encode(message)
            guard let messageDict = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] else { return }
            messageRef.setValue(messageDict)
        } catch { print("Error encoding message for sending: \(error)") }
    }
    
    private func handleError(_ context: String, _ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Error \(context): \(error.localizedDescription)"
            print(self.errorMessage!)
        }
    }
    
    // Cleans up all Firebase listeners and clears local data.
    func unsubscribeAll() {
        if let handle = messagesListenerHandle, let uid = currentUserId { dbRef.child("inbox_messages").child(uid).removeObserver(withHandle: handle); messagesListenerHandle = nil }
        if let handle = transactionsListenerHandle_owner, let uid = currentUserId { dbRef.child("transactions").queryOrdered(byChild: "ownerId").queryEqual(toValue: uid).removeObserver(withHandle: handle); transactionsListenerHandle_owner = nil }
        if let handle = transactionsListenerHandle_borrower, let uid = currentUserId { dbRef.child("transactions").queryOrdered(byChild: "borrowerId").queryEqual(toValue: uid).removeObserver(withHandle: handle); transactionsListenerHandle_borrower = nil }
        currentUserId = nil; inboxMessages = []; relevantTransactions = []
        print("InboxViewModel: Unsubscribed from all listeners and cleared data.")
    }
    deinit { unsubscribeAll() }
        func markMessageAsRead(messageId: String) {
            guard let uid = currentUserId else { return }
            dbRef.child("inbox_messages").child(uid).child(messageId).child("isRead").setValue(true) { error, _ in
                if let error = error {
                    print("Error marking message \(messageId) as read: \(error.localizedDescription)")
                } else {
                    if let index = self.inboxMessages.firstIndex(where: { $0.id == messageId }) {
                        self.inboxMessages[index].isRead = true
                    }
                }
            }
        }
        
        func createAndSaveDummyMessage(
            forUserUid uid: String,
            dateLine: String,
            type: String,
            showsRejectButton: Bool,
            relatedTransactionId: String?,
            lenderName: String?,
            itemName: String?,
            completion: @escaping (Bool, String?) -> Void
        ) {
            let messageId = UUID().uuidString
            let timestamp = Date().timeIntervalSince1970
    
            let newDummyMessage = InboxMessage(
                id: messageId,
                dateLine: dateLine,
                type: type,
                showsRejectButton: showsRejectButton,
                relatedTransactionId: relatedTransactionId,
                timestamp: timestamp,
                isRead: false,
                lenderName: lenderName,
                itemName: itemName
            )
    
            let userInboxRef = dbRef.child("inbox_messages").child(uid).child(messageId)
    
            do {
                let messageData = try JSONEncoder().encode(newDummyMessage)
                guard let messageDict = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] else {
                    completion(false, "Failed to create dictionary from message data.")
                    return
                }
    
                userInboxRef.setValue(messageDict) { error, _ in
                    if let error = error {
                        print("Error saving dummy message: \(error.localizedDescription)")
                        completion(false, error.localizedDescription)
                    } else {
                        print("Dummy message saved successfully to user \(uid)'s inbox.")
                        completion(true, nil)
                    }
                }
            } catch {
                print("Error encoding dummy message: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            }
        }

    func acceptRequest(message: InboxMessage) {
        guard let transactionId = message.relatedTransactionId, let currentUid = self.currentUserId else {
            print("Error: Missing transactionId or currentUserID for acceptRequest")
            return
        }
        
        let transactionRef = dbRef.child("transactions").child(transactionId)
        
        transactionRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, let transactionData = snapshot.value as? [String: Any],
                  let itemId = transactionData["relatedItemId"] as? String,
                  let borrowerId = transactionData["borrowerId"] as? String,
                  let ownerId = transactionData["ownerId"] as? String,
                  ownerId == currentUid else {
                print("Error: Could not fetch transaction, or data missing, or current user is not owner.")
                return
            }
            transactionRef.child("requestStatus").setValue("approved") { error, _ in
                if let error = error {
                    print("Error updating transaction status: \(error.localizedDescription)")
                    return
                }
                
                self.dbRef.child("items").child(itemId).child("isAvailable").setValue(false) { error, _ in
                    if let error = error {
                        print("Error updating item availability: \(error.localizedDescription)")
                        return
                    }
                    
                    let approvalMessageId = UUID().uuidString
                    let itemName = message.itemName ?? "your item" // Use the name from the message
                    let approvalMessage = InboxMessage(
                        id: approvalMessageId,
                        dateLine: "Your request for '\(itemName ?? "item")' has been approved!",
                        type: "request_approved",
                        showsRejectButton: false,
                        relatedTransactionId: transactionId,
                        timestamp: Date().timeIntervalSince1970,
                        isRead: false,
                        lenderName: nil,
                        itemName: message.itemName
                    )
                    self.sendMessage(approvalMessage, toUser: borrowerId)
                    
                    self.markMessageAsRead(messageId: message.id)
                    print("Request approved successfully for transaction: \(transactionId)")
                }
            }
        }
    }
    
    func rejectRequest(message: InboxMessage) {
        guard let transactionId = message.relatedTransactionId, let currentUid = self.currentUserId else {
            print("Error: Missing transactionId or currentUserID for rejectRequest")
            return
        }
    }
}
