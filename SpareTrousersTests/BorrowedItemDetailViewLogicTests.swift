//
//  BorrowedItemDetailViewLogicTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import XCTest
@testable import SpareTrousers // Your app name

// Since BorrowedItemDetailView and its helpers are structs,
// and some formatters are private, we might need to expose them
// or re-declare them for testing if they are complex.
// For simple formatters, we can recreate them in the test.

class BorrowedItemDetailViewLogicTests: XCTestCase {

    // Recreate or expose formatters for testing
    private var testDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Consistent timezone for tests
        return formatter
    }

    private var testTransactionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Consistent timezone for tests
        return formatter
    }
    
    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        // Ensure formatOptions match what the view expects for parsing
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }
    
    // Helper function similar to the one in BorrowedItemDetailView
    // This might need to be extracted from the view or made testable
    private func formatDisplayDateForTest(_ dateString: String?, using specificFormatter: DateFormatter) -> String {
        guard let dateStr = dateString else { return "N/A" }
        
        // Primary ISO formatter
        let primaryIsoFormatter = ISO8601DateFormatter()
        primaryIsoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = primaryIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        
        // Fallback ISO formatter (without fractional seconds, common in some ISO strings)
        let fallbackIsoFormatter = ISO8601DateFormatter()
        fallbackIsoFormatter.formatOptions = [.withInternetDateTime, .withTimeZone] // Example, adjust to match view's fallback
        if let date = fallbackIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        
        // Fallback ISO formatter (only date and time, no timezone info in string)
        let noTimezoneIsoFormatter = ISO8601DateFormatter()
        noTimezoneIsoFormatter.formatOptions = [.withInternetDateTime]
         if let date = noTimezoneIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }

        // print("Test Warning: Could not parse date string: \(dateStr)")
        return "N/A"
    }


    func testFormatDisplayDate_ValidISO_WithFractionalSecondsAndTimezone() {
        let isoDateString = "2025-06-05T14:30:15.123Z" // Zulu timezone (UTC)
        let formatted = formatDisplayDateForTest(isoDateString, using: testDateFormatter)
        // Expected output depends on the testDateFormatter's locale and timezone.
        // Since testDateFormatter is set to GMT:0
        XCTAssertEqual(formatted, "5 Jun 2025 at 14.30")
    }

    
    func testFormatDisplayDate_ValidISO_NoFractionalSeconds() {
        // This tests the fallback logic in formatDisplayDateForTest
        let isoDateString = "2025-07-10T10:00:00+07:00" // GMT+7
        let formatted = formatDisplayDateForTest(isoDateString, using: testTransactionDateFormatter)
         // testTransactionDateFormatter is medium date style, GMT:0.
         // 2025-07-10T10:00:00+07:00 is 2025-07-10T03:00:00Z
        XCTAssertEqual(formatted, "10 Jul 2025")
    }

    func testFormatDisplayDate_NilInput() {
        let formatted = formatDisplayDateForTest(nil, using: testDateFormatter)
        XCTAssertEqual(formatted, "N/A")
    }

    func testFormatDisplayDate_InvalidDateString() {
        let invalidDateString = "not a date"
        let formatted = formatDisplayDateForTest(invalidDateString, using: testDateFormatter)
        XCTAssertEqual(formatted, "N/A")
    }
    
    func testArrayRemovingDuplicates() {
        let arrayWithDuplicates = ["apple", "banana", "apple", "orange", "banana", "banana"]
        let expectedArray = ["apple", "banana", "orange"] // Order might vary based on filter implementation
        let uniqueArray = arrayWithDuplicates.removingDuplicates()
        
        XCTAssertEqual(uniqueArray.count, expectedArray.count)
        for item in expectedArray {
            XCTAssertTrue(uniqueArray.contains(item))
        }

        let arrayWithoutDuplicates = ["a", "b", "c"]
        XCTAssertEqual(arrayWithoutDuplicates.removingDuplicates(), ["a", "b", "c"])

        let emptyArray: [String] = []
        XCTAssertEqual(emptyArray.removingDuplicates(), [])
    }
}

// Expose the extension for testing if it's not already in a shared module
// If Array.removingDuplicates() is an extension in your main app target, it should be accessible.
// No need to redefine unless it's private or fileprivate.
