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

    private var dbRef: DatabaseReference!
    private var inboxListenerHandle: DatabaseHandle?
    private var currentUserID: String?

    init() {
        self.dbRef = Database.database().reference()
        
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            fetchInboxMessages()
        } else {
            self.errorMessage = "User not logged in. Cannot fetch inbox."
            print(errorMessage!)
        }
    }

    deinit {
        if let handle = inboxListenerHandle, let userID = currentUserID {
            dbRef
                .child("userInboxMessages")
                .child(userID)
                .removeObserver(withHandle: handle)
        }
        print("InboxViewModel deinitialized.")
    }

    func fetchInboxMessages() {
        guard let userID = currentUserID else {
            errorMessage = "Cannot fetch inbox: User ID is missing."
            print(errorMessage!)
            return
        }

        isLoading = true
        errorMessage = nil
        
        let userInboxRef = dbRef.child("userInboxMessages").child(userID)
        
        if let handle = inboxListenerHandle {
            userInboxRef.removeObserver(withHandle: handle)
        }

        inboxListenerHandle = userInboxRef
            .observe(
.value,
 with: { [weak self] (snapshot: DataSnapshot) in
     guard let self = self else { return }
     print(
        "Firebase: Inbox messages snapshot received for user \(userID)"
     )

     var fetchedMessages: [InboxMessage] = []
     if let value = snapshot.value as? [String: Any] {
         for (messageId, messageData) in value {
             if let messageDict = messageData as? [String: Any] {
                 if let inboxMessage = InboxMessage(
                    id: messageId,
                    dictionary: messageDict
                 ) {
                     fetchedMessages.append(inboxMessage)
                 } else {
                     print(
                        "Warning: Failed to parse FirebaseInboxMessage for ID: \(messageId)"
                     )
                 }
             }
         }
     } else if !snapshot.exists() {
         print("Firebase: No inbox messages found for user \(userID).")
     } else {
         print(
            "Error: Inbox messages snapshot.value is not [String: Any] or is null for user \(userID). Type: \(type(of: snapshot.value))"
         )
     }
            
     DispatchQueue.main.async {
         self.isLoading = false
         self.inboxMessages = fetchedMessages
             .sorted(by: { $0.timestamp > $1.timestamp })
         print(
            "Fetched and processed \(self.inboxMessages.count) inbox messages."
         )
     }

 },
withCancel: { [weak self] error in
    guard let self = self else { return }
    DispatchQueue.main.async {
        self.isLoading = false
        self.errorMessage = "Error fetching inbox messages: \(error.localizedDescription)"
        print(self.errorMessage!)
    }
})
    }

    // MARK: - Action Handlers (Placeholders - Implement actual Firebase updates)

    func acceptRequest(message: InboxMessage) {
        print(
            "Accepted request for message: \(message.id), related transaction: \(message.relatedTransactionId ?? "N/A")"
        )
        // TODO: Implement Firebase logic:
        // 1. Update the status of the related RentalTransaction in Firebase.
        // 2. Potentially create new inbox messages for involved users (e.g., confirmation to borrower).
        // 3. Mark this inbox message as "handled" or delete it, or update its 'isRead' status.
        markMessageAsRead(messageId: message.id) // Example
    }

    func rejectRequest(message: InboxMessage) {
        print(
            "Rejected request for message: \(message.id), related transaction: \(message.relatedTransactionId ?? "N/A")"
        )
        // TODO: Implement Firebase logic:
        // 1. Update the status of the related RentalTransaction in Firebase (e.g., "rejected").
        // 2. Potentially create new inbox message for borrower.
        // 3. Mark this inbox message as "handled" or delete it.
        markMessageAsRead(messageId: message.id) // Example
    }

    func markMessageAsRead(messageId: String) {
        guard let userID = currentUserID else { return }
        let messageRef = dbRef.child("userInboxMessages").child(userID).child(messageId).child(
            "isRead"
        )
        messageRef.setValue(true) {
 error,
 _ in
            if let error = error {
                print(
                    "Error marking message \(messageId) as read: \(error.localizedDescription)"
                )
            } else {
                print("Message \(messageId) marked as read.")
            }
        }
    }
    
    func createDummyInboxItem(
        messageText: String,
        dateLine: String,
        type: String,
        showsReject: Bool,
        relatedItemName: String = "Sample Item"
    ) {
        guard let userID = currentUserID else {
            self.errorMessage = "Cannot create dummy inbox item: User not logged in."
            print(self.errorMessage!)
            return
        }

        // Generate a unique ID for the new inbox message
        guard let newMessageID = dbRef.child("userInboxMessages").child(userID).childByAutoId().key else {
            self.errorMessage = "Could not generate new message ID."
            print(self.errorMessage!)
            return
        }

        let dummyMessageData: [String: Any] = [
            "messageText": messageText,
            "dateLine": dateLine,
            "type": type,
            "showsRejectButton": showsReject,
            "relatedItemId": "DUMMY_ITEM_ID_\(Int.random(in: 100...999))", // Placeholder
            "relatedTransactionId": "DUMMY_TRANS_ID_\(Int.random(in: 100...999))", // Placeholder
            "timestamp": ServerValue
                .timestamp(), // Use Firebase server timestamp for ordering
            "isRead": false,
            "lenderName": "Test Sender", // Or "borrowerName"
            "itemName": relatedItemName
        ]

        dbRef
            .child("userInboxMessages")
            .child(userID)
            .child(newMessageID)
            .setValue(dummyMessageData) {
 [weak self] error,
 _ in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Error creating dummy inbox item: \(error.localizedDescription)"
                        print(self!.errorMessage!)
                    } else {
                        print(
                            "Dummy inbox item created successfully with ID: \(newMessageID)"
                        )
                        // The .observe(.value) listener in fetchInboxMessages will automatically pick up this new item.
                    }
                }
            }
    }
}
