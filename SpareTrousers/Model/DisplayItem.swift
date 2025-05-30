//
//  DisplayItem.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//


import SwiftUI

// MARK: - DisplayItem (Updated to include description)
struct DisplayItem: Identifiable {
    let id: String // Firebase key
    let name: String
    let imageName: String
    let rentalPrice: String
    let categoryId: Int
    let description: String // Added description field
    // Add other fields like isAvailable, ownerUid if needed directly in DisplayItem for UI
    let isAvailable: Bool? // Optional, as it might not always be present or needed for display
    let ownerUid: String?  // Optional
    let status: Bool = true
}
