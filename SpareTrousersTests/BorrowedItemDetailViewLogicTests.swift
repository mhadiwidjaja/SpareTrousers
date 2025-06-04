//
//  BorrowedItemDetailViewLogicTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import XCTest
@testable import SpareTrousers

class BorrowedItemDetailViewLogicTests: XCTestCase {

    // Recreate or expose formatters for testing
    private var testDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

    private var testTransactionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }
    
    private func formatDisplayDateForTest(_ dateString: String?, using specificFormatter: DateFormatter) -> String {
        guard let dateStr = dateString else { return "N/A" }
        
        // Primary ISO formatter
        let primaryIsoFormatter = ISO8601DateFormatter()
        primaryIsoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = primaryIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        
        // Fallback ISO formatter
        let fallbackIsoFormatter = ISO8601DateFormatter()
        fallbackIsoFormatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        if let date = fallbackIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        
        // Fallback ISO formatter (only date and time, no timezone info in string)
        let noTimezoneIsoFormatter = ISO8601DateFormatter()
        noTimezoneIsoFormatter.formatOptions = [.withInternetDateTime]
         if let date = noTimezoneIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }

        return "N/A"
    }


    func testFormatDisplayDate_ValidISO_WithFractionalSecondsAndTimezone() {
        let isoDateString = "2025-06-05T14:30:15.123Z"
        let formatted = formatDisplayDateForTest(isoDateString, using: testDateFormatter)
        XCTAssertEqual(formatted, "5 Jun 2025 at 14.30")
    }

    
    func testFormatDisplayDate_ValidISO_NoFractionalSeconds() {
        let isoDateString = "2025-07-10T10:00:00+07:00"
        let formatted = formatDisplayDateForTest(isoDateString, using: testTransactionDateFormatter)
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
        let expectedArray = ["apple", "banana", "orange"]
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
