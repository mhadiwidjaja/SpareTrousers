//
//  CategoryItem.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//


import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String // SF Symbol name
    let color: Color
}