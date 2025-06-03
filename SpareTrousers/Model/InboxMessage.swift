//
//  InboxMessage.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import Foundation

struct InboxMessage: Identifiable, Encodable {
    let id: String
    let dateLine: String
    let type: String
    let showsRejectButton: Bool
    let relatedTransactionId: String?
    let timestamp: TimeInterval
    var isRead: Bool
    let lenderName: String?
    let itemName: String?

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
        self.lenderName = dictionary["lenderName"] as? String
        self.itemName = dictionary["itemName"] as? String
    }

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
