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
//
//class InboxViewModel: ObservableObject {
//    @Published var inboxMessages: [InboxMessage] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    private var dbRef: DatabaseReference!
//    private var inboxListenerHandle: DatabaseHandle?
//    private var currentUserID: String?
//
//    init() {
//        self.dbRef = Database.database().reference()
//        
//        if let user = Auth.auth().currentUser {
//            self.currentUserID = user.uid
//            fetchInboxMessages()
//        } else {
//            self.errorMessage = "User not logged in. Cannot fetch inbox."
//            print(errorMessage!)
//        }
//    }
//
//    deinit {
//        if let handle = inboxListenerHandle, let userID = currentUserID {
//            dbRef
//                .child("userInboxMessages")
//                .child(userID)
//                .removeObserver(withHandle: handle)
//        }
//        print("InboxViewModel deinitialized.")
//    }
//
//    func fetchInboxMessages() {
//        guard let userID = currentUserID else {
//            errorMessage = "Cannot fetch inbox: User ID is missing."
//            print(errorMessage!)
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//        
//        let userInboxRef = dbRef.child("userInboxMessages").child(userID)
//        
//        if let handle = inboxListenerHandle {
//            userInboxRef.removeObserver(withHandle: handle)
//        }
//
//        inboxListenerHandle = userInboxRef
//            .observe(
//.value,
// with: { [weak self] (snapshot: DataSnapshot) in
//     guard let self = self else { return }
//     print(
//        "Firebase: Inbox messages snapshot received for user \(userID)"
//     )
//
//     var fetchedMessages: [InboxMessage] = []
//     if let value = snapshot.value as? [String: Any] {
//         for (messageId, messageData) in value {
//             if let messageDict = messageData as? [String: Any] {
//                 if let inboxMessage = InboxMessage(
//                    id: messageId,
//                    dictionary: messageDict
//                 ) {
//                     fetchedMessages.append(inboxMessage)
//                 } else {
//                     print(
//                        "Warning: Failed to parse FirebaseInboxMessage for ID: \(messageId)"
//                     )
//                 }
//             }
//         }
//     } else if !snapshot.exists() {
//         print("Firebase: No inbox messages found for user \(userID).")
//     } else {
//         print(
//            "Error: Inbox messages snapshot.value is not [String: Any] or is null for user \(userID). Type: \(type(of: snapshot.value))"
//         )
//     }
//            
//     DispatchQueue.main.async {
//         self.isLoading = false
//         self.inboxMessages = fetchedMessages
//             .sorted(by: { $0.timestamp > $1.timestamp })
//         print(
//            "Fetched and processed \(self.inboxMessages.count) inbox messages."
//         )
//     }
//
// },
//withCancel: { [weak self] error in
//    guard let self = self else { return }
//    DispatchQueue.main.async {
//        self.isLoading = false
//        self.errorMessage = "Error fetching inbox messages: \(error.localizedDescription)"
//        print(self.errorMessage!)
//    }
//})
//    }
//
//    // MARK: - Action Handlers (Placeholders - Implement actual Firebase updates)
//
//    func acceptRequest(message: InboxMessage) {
//        print(
//            "Accepted request for message: \(message.id), related transaction: \(message.relatedTransactionId ?? "N/A")"
//        )
//        // TODO: Implement Firebase logic:
//        // 1. Update the status of the related RentalTransaction in Firebase.
//        // 2. Potentially create new inbox messages for involved users (e.g., confirmation to borrower).
//        // 3. Mark this inbox message as "handled" or delete it, or update its 'isRead' status.
//        markMessageAsRead(messageId: message.id) // Example
//    }
//
//    func rejectRequest(message: InboxMessage) {
//        print(
//            "Rejected request for message: \(message.id), related transaction: \(message.relatedTransactionId ?? "N/A")"
//        )
//        // TODO: Implement Firebase logic:
//        // 1. Update the status of the related RentalTransaction in Firebase (e.g., "rejected").
//        // 2. Potentially create new inbox message for borrower.
//        // 3. Mark this inbox message as "handled" or delete it.
//        markMessageAsRead(messageId: message.id) // Example
//    }
//
//    func markMessageAsRead(messageId: String) {
//        guard let userID = currentUserID else { return }
//        let messageRef = dbRef.child("userInboxMessages").child(userID).child(messageId).child(
//            "isRead"
//        )
//        messageRef.setValue(true) {
// error,
// _ in
//            if let error = error {
//                print(
//                    "Error marking message \(messageId) as read: \(error.localizedDescription)"
//                )
//            } else {
//                print("Message \(messageId) marked as read.")
//            }
//        }
//    }
//    
//    func createDummyInboxItem(
//        messageText: String,
//        dateLine: String,
//        type: String,
//        showsReject: Bool,
//        relatedItemName: String = "Sample Item"
//    ) {
//        guard let userID = currentUserID else {
//            self.errorMessage = "Cannot create dummy inbox item: User not logged in."
//            print(self.errorMessage!)
//            return
//        }
//
//        // Generate a unique ID for the new inbox message
//        guard let newMessageID = dbRef.child("userInboxMessages").child(userID).childByAutoId().key else {
//            self.errorMessage = "Could not generate new message ID."
//            print(self.errorMessage!)
//            return
//        }
//
//        let dummyMessageData: [String: Any] = [
//            "messageText": messageText,
//            "dateLine": dateLine,
//            "type": type,
//            "showsRejectButton": showsReject,
//            "relatedTransactionId": "DUMMY_TRANS_ID_\(Int.random(in: 100...999))", // Placeholder
//            "timestamp": ServerValue
//                .timestamp(), // Use Firebase server timestamp for ordering
//            "isRead": false,
//            "lenderName": "Test Sender", // Or "borrowerName"
//            "itemName": relatedItemName
//        ]
//
//        dbRef
//            .child("userInboxMessages")
//            .child(userID)
//            .child(newMessageID)
//            .setValue(dummyMessageData) {
// [weak self] error,
// _ in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        self?.errorMessage = "Error creating dummy inbox item: \(error.localizedDescription)"
//                        print(self!.errorMessage!)
//                    } else {
//                        print(
//                            "Dummy inbox item created successfully with ID: \(newMessageID)"
//                        )
//                        // The .observe(.value) listener in fetchInboxMessages will automatically pick up this new item.
//                    }
//                }
//            }
//    }
//}

class InboxViewModel: ObservableObject {
    @Published var inboxMessages: [InboxMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var dbRef: DatabaseReference!
    private var messagesListenerHandle: DatabaseHandle?
    private var currentUserId: String?

    init() {
        dbRef = Database.database().reference()
    }

    func subscribeToInboxMessages(forUser uid: String) {
        // If already listening for this user, or a different user, first remove old listener
        if let handle = messagesListenerHandle {
            if let previousUid = currentUserId {
                 dbRef.child("inbox_messages").child(previousUid).removeObserver(withHandle: handle)
            } else { // Should not happen if currentUserId is managed properly
                 dbRef.child("inbox_messages").removeObserver(withHandle: handle) // General removal if UID was unclear
            }
            messagesListenerHandle = nil
        }
        
        currentUserId = uid // Store current user ID
        isLoading = true
        errorMessage = nil
        inboxMessages = [] // Clear previous messages

        let userMessagesRef = dbRef.child("inbox_messages").child(uid)
        
        messagesListenerHandle = userMessagesRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            print("InboxViewModel: Received inbox messages snapshot for user \(uid)")
            self.isLoading = false
            var fetchedMessages: [InboxMessage] = []

            if snapshot.exists(), let children = snapshot.children.allObjects as? [DataSnapshot] {
                for childSnapshot in children {
                    if let messageData = childSnapshot.value as? [String: Any] {
                        // Use the failable initializer from your InboxMessage struct
                        if let message = InboxMessage(id: childSnapshot.key, dictionary: messageData) {
                            fetchedMessages.append(message)
                        } else {
                            print("InboxViewModel: Failed to parse message with ID \(childSnapshot.key), data: \(messageData)")
                        }
                    }
                }
            } else {
                print("InboxViewModel: No messages found for user \(uid) or snapshot is empty.")
            }
            
            // Sort messages by timestamp, newest first
            self.inboxMessages = fetchedMessages.sorted(by: { $0.timestamp > $1.timestamp })
            if self.inboxMessages.isEmpty && snapshot.exists() {
                print("InboxViewModel: Messages were present in snapshot but parsing failed or resulted in empty array.")
            } else if self.inboxMessages.isEmpty {
                 print("InboxViewModel: Inbox is empty for user \(uid).")
            }

        }) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error fetching inbox messages: \(error.localizedDescription)"
                print(self.errorMessage!)
            }
        }
    }
    
    // Call this when the view disappears or user logs out
    func unsubscribeFromInboxMessages() {
        if let handle = messagesListenerHandle, let uid = currentUserId {
            dbRef.child("inbox_messages").child(uid).removeObserver(withHandle: handle)
            messagesListenerHandle = nil
            currentUserId = nil
            inboxMessages = [] // Clear messages on unsubscribe
            print("InboxViewModel: Unsubscribed from inbox messages for user \(uid)")
        }
    }

    deinit {
        unsubscribeFromInboxMessages() // Ensure listener is removed on deinit
    }
    
    // Optional: Function to mark a message as read (example)
    func markMessageAsRead(messageId: String) {
        guard let uid = currentUserId else { return }
        dbRef.child("inbox_messages").child(uid).child(messageId).child("isRead").setValue(true) { error, _ in
            if let error = error {
                print("Error marking message \(messageId) as read: \(error.localizedDescription)")
            } else {
                // Optionally update local model, though listener should pick up the change
                if let index = self.inboxMessages.firstIndex(where: { $0.id == messageId }) {
                    self.inboxMessages[index].isRead = true
                }
            }
        }
    }
    
    func createAndSaveDummyMessage(
        forUserUid uid: String, // Explicitly pass UID to ensure message goes to correct user
        dateLine: String,
        type: String,
        showsRejectButton: Bool,
        relatedTransactionId: String?,
        lenderName: String?, // Name of the other party
        itemName: String?,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let messageId = UUID().uuidString // Generate a unique ID for the new message
        let timestamp = Date().timeIntervalSince1970

        let newDummyMessage = InboxMessage(
            id: messageId,
            dateLine: dateLine,
            type: type,
            showsRejectButton: showsRejectButton,
            relatedTransactionId: relatedTransactionId,
            timestamp: timestamp,
            isRead: false, // New messages are unread
            lenderName: lenderName,
            itemName: itemName
        )

        let userInboxRef = dbRef.child("inbox_messages").child(uid).child(messageId)

        do {
            // Assuming InboxMessage is Encodable
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
}
