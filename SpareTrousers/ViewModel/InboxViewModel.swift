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
                    let approvalMessage = InboxMessage(
                        id: approvalMessageId,
                        dateLine: "Your request for '\(message.itemName ?? "item")' has been approved!",
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

        let transactionRef = dbRef.child("transactions").child(transactionId)

        transactionRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, let transactionData = snapshot.value as? [String: Any],
                  let borrowerId = transactionData["borrowerId"] as? String,
                  let ownerId = transactionData["ownerId"] as? String,
                  ownerId == currentUid else {
                print("Error: Could not fetch transaction for rejection or not owner.")
                return
            }

            transactionRef.removeValue { error, _ in
                if let error = error {
                    print("Error deleting transaction: \(error.localizedDescription)")
                    return
                }
                let declinedMessageId = UUID().uuidString
                let declinedMessage = InboxMessage(
                    id: declinedMessageId,
                    dateLine: "Your request for '\(message.itemName ?? "item")' has been declined.",
                    type: "request_declined",
                    showsRejectButton: false,
                    relatedTransactionId: transactionId,
                    timestamp: Date().timeIntervalSince1970,
                    isRead: false,
                    lenderName: nil,
                    itemName: message.itemName
                )
                self.sendMessage(declinedMessage, toUser: borrowerId)

                self.markMessageAsRead(messageId: message.id)
                print("Request declined and transaction deleted for: \(transactionId)")
            }
        }
    }

    func acceptReturnReminder(message: InboxMessage) {
        guard let transactionId = message.relatedTransactionId,
              let itemId = message.itemName,
              let currentUid = self.currentUserId else {
            print("Error: Missing data for acceptReturnReminder")
            return
        }
        dbRef.child("transactions").child(transactionId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, let transactionData = snapshot.value as? [String: Any],
                  let actualItemId = transactionData["relatedItemId"] as? String,
                  let ownerId = transactionData["ownerId"] as? String,
                  ownerId == currentUid else {
                print("Error: Could not fetch transaction for return or not owner.")
                return
            }
            self.dbRef.child("items").child(actualItemId).child("isAvailable").setValue(true) { error, _ in
                if let error = error {
                    print("Error updating item availability on return: \(error.localizedDescription)")
                    return
                }

                self.dbRef.child("transactions").child(transactionId).child("requestStatus").setValue("completed")

                self.markMessageAsRead(messageId: message.id)
                print("Item return accepted for item: \(actualItemId), transaction: \(transactionId)")
            }
        }
    }


    private func sendMessage(_ message: InboxMessage, toUser userId: String) {
        let messageRef = dbRef.child("inbox_messages").child(userId).child(message.id)
        do {
            let messageData = try JSONEncoder().encode(message)
            guard let messageDict = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] else {
                print("Error: Could not serialize message for sending.")
                return
            }
            messageRef.setValue(messageDict) { error, _ in
                if let error = error {
                    print("Error sending message \(message.id) to user \(userId): \(error.localizedDescription)")
                } else {
                    print("Message \(message.id) sent successfully to user \(userId).")
                }
            }
        } catch {
            print("Error encoding message for sending: \(error.localizedDescription)")
        }
    }

}
