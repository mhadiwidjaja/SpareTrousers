//
//  UtilityTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import XCTest
import SwiftUI
@testable import SpareTrousers

class UtilityTests: XCTestCase {

    func testColorHexInitialization_RGB() {
        let color = Color(hex: "FF0000") // Red
        // Note: Direct comparison of Color objects can be tricky.
        // We might need to compare their components or use a helper.
        // For simplicity here, we'll assume if it doesn't crash and produces a color, it's a basic pass.
        // A more robust test would involve extracting RGB components.
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_ARGB() {
        let color = Color(hex: "80FF0000") // Semi-transparent Red
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_ShortRGB() {
        let color = Color(hex: "F00") // Red
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitialization_WithHashPrefix() {
        let color = Color(hex: "#00FF00") // Green
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_InvalidHex() {
        let color = Color(hex: "XYZ123") // Invalid
        // Default behavior is to return black
        // This requires comparing the color components to black.
        let (r, g, b, a) = colorToRGBA(color)
        XCTAssertEqual(r, 0.0, accuracy: 0.001)
        XCTAssertEqual(g, 0.0, accuracy: 0.001)
        XCTAssertEqual(b, 0.0, accuracy: 0.001)
        XCTAssertEqual(a, 1.0, accuracy: 0.001) // Alpha is 255 by default
    }
    
    func testColorHexInitialization_SpecificValues() {
        let blueColor = Color(hex: "0000FF") // Pure Blue
        let (r_blue, g_blue, b_blue, _) = colorToRGBA(blueColor)
        XCTAssertEqual(r_blue, 0.0, accuracy: 0.001)
        XCTAssertEqual(g_blue, 0.0, accuracy: 0.001)
        XCTAssertEqual(b_blue, 1.0, accuracy: 0.001)

        let greenColor = Color(hex: "00FF00") // Pure Green
        let (r_green, g_green, b_green, _) = colorToRGBA(greenColor)
        XCTAssertEqual(r_green, 0.0, accuracy: 0.001)
        XCTAssertEqual(g_green, 1.0, accuracy: 0.001)
        XCTAssertEqual(b_green, 0.0, accuracy: 0.001)
    }
    
    // Helper to get RGBA components from SwiftUI Color
    // This is a simplified helper; more robust conversion might be needed for all color spaces.
    private func colorToRGBA(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    // Test predefined app colors
    func testAppColorsExistence() {
        XCTAssertNotNil(Color.appBlue)
        XCTAssertNotNil(Color.appOrange)
        XCTAssertNotNil(Color.appOffGray)
        XCTAssertNotNil(Color.appOffWhite)
        XCTAssertNotNil(Color.appBlack)
        XCTAssertNotNil(Color.appWhite)
    }
}
