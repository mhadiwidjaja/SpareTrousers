//
//  Transaction.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct Transaction: Identifiable, Encodable { // Made Encodable
    let id: String // Should be unique, e.g., UUID().uuidString or Firebase autoId
    let transactionDate: String // ISO8601 formatted date string
    let startTime: String       // ISO8601 formatted date string for start
    let endTime: String         // ISO8601 formatted date string for end
    let relatedItemId: String   // item.id of the transaction
    let ownerId: String
    let borrowerId: String
    // Add a status field, e.g., "pending", "approved", "declined", "completed"
    var requestStatus: String = "pending" // Default status

    // Helper to convert to dictionary for Firebase, if not using Encodable directly with DatabaseReference
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "transactionDate": transactionDate,
            "startTime": startTime,
            "endTime": endTime,
            "relatedItemId": relatedItemId,
            "ownerId": ownerId,
            "borrowerId": borrowerId,
            "requestStatus": requestStatus
        ]
    }
}
