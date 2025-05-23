//
//  DisplayItem.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//


import SwiftUI

struct DisplayItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Placeholder for actual image loading
    let rentalPrice: String
}