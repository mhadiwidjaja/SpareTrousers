//
//  AppColors.swift
//  SpareTrousers
//
//  Created by student on 23/05/25.
//

import SwiftUI

extension Color {
    // Blue
    static let appBlue = Color(hex: "009CFD")
    // Orange
    static let appOrange = Color(hex: "FDA200")
    // OffGray
    static let appOffGray = Color(hex: "4F767E")
    // OffWhite
    static let appOffWhite = Color(hex: "C7DADD")
    // Black
    static let appBlack = Color(hex: "2F2F2F")
    // White
    static let appWhite = Color(hex: "FAFAFA")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
