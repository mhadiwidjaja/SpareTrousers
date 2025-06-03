//
//  InboxMessage.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//


import Foundation



//struct InboxMessage: Identifiable {
//    let id: String // Unique identifier for the message
//
//    // Details about the message content and type
//    let dateLine: String            // Formatted date string for display
//    let type: String                // Type of message (e.g., "request_received", "request_approved")
//    let showsRejectButton: Bool     // Whether UI should show a reject button for this message
//    let relatedTransactionId: String? // Optional ID linking to a Transaction
//    let timestamp: TimeInterval     // Timestamp for sorting or detailed date information
//    var isRead: Bool                // Read status of the message
//
//    // Optional details about participants or items involved
//    let lenderName: String?         // Name of the lender, if applicable
//    let itemName: String?           // Name of the item, if applicable
//
//    // Failable initializer to create an InboxMessage from a dictionary (e.g., from Firebase)
//    init?(id: String, dictionary: [String: Any]) {
//        // Use guard let to safely unwrap optional values from the dictionary
//        // Each condition is separated by a comma.
//        guard let dateLine = dictionary["dateLine"] as? String,
//              let type = dictionary["type"] as? String,
//              let showsRejectButton = dictionary["showsRejectButton"] as? Bool,
//              let timestamp = dictionary["timestamp"] as? TimeInterval
//        else {
//            // If any of the essential fields are missing or not of the expected type,
//            // print an error and return nil, causing the initialization to fail.
//            print("Error: Missing essential fields for InboxMessage with id \(id). Dictionary: \(dictionary)")
//            return nil
//        }
//
//        // Assign the unwrapped essential values
//        self.id = id
//        self.dateLine = dateLine
//        self.type = type
//        self.showsRejectButton = showsRejectButton
//        self.timestamp = timestamp
//
//        // Assign optional values, providing defaults if they are missing
//        self.isRead = dictionary["isRead"] as? Bool ?? false // Default to false if not present
//        self.relatedTransactionId = dictionary["relatedTransactionId"] as? String
//        self.lenderName = dictionary["lenderName"] as? String
//        self.itemName = dictionary["itemName"] as? String
//    }
//
//    // Example memberwise initializer (Swift provides one automatically if no custom initializers are failable)
//    // You might use this for creating local instances or for testing.
//    init(id: String, dateLine: String, type: String, showsRejectButton: Bool, relatedTransactionId: String?, timestamp: TimeInterval, isRead: Bool, lenderName: String?, itemName: String?) {
//        self.id = id
//        self.dateLine = dateLine
//        self.type = type
//        self.showsRejectButton = showsRejectButton
//        self.relatedTransactionId = relatedTransactionId
//        self.timestamp = timestamp
//        self.isRead = isRead
//        self.lenderName = lenderName
//        self.itemName = itemName
//    }
//}

struct InboxMessage: Identifiable, Encodable { // Made Encodable
    let id: String
    let dateLine: String
    let type: String
    let showsRejectButton: Bool
    let relatedTransactionId: String?
    let timestamp: TimeInterval
    var isRead: Bool
    let lenderName: String?         // Name of the other party (borrower in this case for owner's inbox)
    let itemName: String?

    // Failable initializer (if needed, but for sending, we use the memberwise one)
    init?(id: String, dictionary: [String: Any]) {
        guard let dateLine = dictionary["dateLine"] as? String,
              let type = dictionary["type"] as? String,
              let showsRejectButton = dictionary["showsRejectButton"] as? Bool,
              let timestamp = dictionary["timestamp"] as? TimeInterval
        else {
            print("Error: Missing essential fields for InboxMessage with id \(id). Dictionary: \(dictionary)")
            return nil
        }
        self.id = id
        self.dateLine = dateLine
        self.type = type
        self.showsRejectButton = showsRejectButton
        self.timestamp = timestamp
        self.isRead = dictionary["isRead"] as? Bool ?? false
        self.relatedTransactionId = dictionary["relatedTransactionId"] as? String
        self.lenderName = dictionary["lenderName"] as? String // Corresponds to borrower's name/ID
        self.itemName = dictionary["itemName"] as? String
    }

    // Memberwise initializer for creating new messages
    init(id: String, dateLine: String, type: String, showsRejectButton: Bool, relatedTransactionId: String?, timestamp: TimeInterval, isRead: Bool, lenderName: String?, itemName: String?) {
        self.id = id
        self.dateLine = dateLine
        self.type = type
        self.showsRejectButton = showsRejectButton
        self.relatedTransactionId = relatedTransactionId
        self.timestamp = timestamp
        self.isRead = isRead
        self.lenderName = lenderName
        self.itemName = itemName
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "dateLine": dateLine,
            "type": type,
            "showsRejectButton": showsRejectButton,
            "relatedTransactionId": relatedTransactionId ?? NSNull(),
            "timestamp": timestamp,
            "isRead": isRead,
            "lenderName": lenderName ?? NSNull(),
            "itemName": itemName ?? NSNull()
        ]
    }
}
