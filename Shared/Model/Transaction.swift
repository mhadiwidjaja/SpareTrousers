//
//  Transaction.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct Transaction: Identifiable, Codable {
    let id: String
    let transactionDate: String
    let startTime: String
    let endTime: String
    let relatedItemId: String
    let ownerId: String
    let borrowerId: String
    var requestStatus: String = "pending"
    
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
