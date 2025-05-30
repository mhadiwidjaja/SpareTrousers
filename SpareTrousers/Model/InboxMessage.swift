//
//  InboxMessage.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//


import Foundation

struct InboxMessage: Identifiable {
    let id: String
    let messageText: String
    let dateLine: String
    let type: String
    let showsRejectButton: Bool
    let relatedItemId: String?
    let relatedTransactionId: String?
    let timestamp: TimeInterval
    var isRead: Bool
    let lenderName: String?
    let itemName: String?

    init?(id: String, dictionary: [String: Any]) {
        guard let messageText = dictionary["messageText"] as? String,
              let dateLine = dictionary["dateLine"] as? String,
              let type = dictionary["type"] as? String,
              let showsRejectButton = dictionary["showsRejectButton"] as? Bool,
              let timestamp = dictionary["timestamp"] as? TimeInterval
        else {
            print("Error: Missing essential fields for FirebaseInboxMessage with id \(id)")
            return nil
        }

        self.id = id
        self.messageText = messageText
        self.dateLine = dateLine
        self.type = type
        self.showsRejectButton = showsRejectButton
        self.timestamp = timestamp
        self.isRead = dictionary["isRead"] as? Bool ?? false
        self.relatedItemId = dictionary["relatedItemId"] as? String
        self.relatedTransactionId = dictionary["relatedTransactionId"] as? String
        self.lenderName = dictionary["lenderName"] as? String
        self.itemName = dictionary["itemName"] as? String
    }
}
