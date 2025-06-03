//
//  Transaction.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct Transaction: Identifiable {
    let id: String
    let TransactionDate: String
    let StartTime: String
    let EndTime: String
    let RelatedItemId: String
    let OwnerId: String
    let BorrowerId: String
}
