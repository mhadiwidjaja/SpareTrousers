//
//  DisplayItem.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//


import SwiftUI

struct DisplayItem: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let rentalPrice: String
    let categoryId: Int
    let status: Bool = true
}
