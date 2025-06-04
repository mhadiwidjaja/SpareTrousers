//
//  ModelTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//


import XCTest
import SwiftUI
@testable import SpareTrousers

class ModelTests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    func testCategoryItemInitialization() {
        let category = CategoryItem(id: 1, name: "Fashion", iconName: "tshirt.fill", color: .blue)
        XCTAssertEqual(category.id, 1)
        XCTAssertEqual(category.name, "Fashion")
        XCTAssertEqual(category.iconName, "tshirt.fill")
        XCTAssertEqual(category.color, .blue)
    }

    func testDisplayItemInitialization() {
        let item = DisplayItem(
            id: "item123",
            name: "Cool Trousers",
            imageName: "trousers.png",
            rentalPrice: "Rp 50.000 /day",
            categoryId: 1,
            description: "Very cool trousers for rent.",
            isAvailable: true,
            ownerUid: "user456"
        )
        XCTAssertEqual(item.id, "item123")
        XCTAssertEqual(item.name, "Cool Trousers")
        XCTAssertEqual(item.imageName, "trousers.png")
        XCTAssertEqual(item.rentalPrice, "Rp 50.000 /day")
        XCTAssertEqual(item.categoryId, 1)
        XCTAssertEqual(item.description, "Very cool trousers for rent.")
        XCTAssertEqual(item.isAvailable, true)
        XCTAssertEqual(item.ownerUid, "user456")
        XCTAssertTrue(item.status) // Default value
    }

    func testInboxMessageInitializationWithDictionary() {
        let timestamp = Date().timeIntervalSince1970
        let messageDict: [String: Any] = [
            "dateLine": "New Request",
            "type": "request_received",
            "showsRejectButton": true,
            "timestamp": timestamp,
            "isRead": false,
            "relatedTransactionId": "txn789",
            "lenderName": "John Doe",
            "itemName": "Hammer"
        ]

        let message = InboxMessage(id: "msg001", dictionary: messageDict)

        XCTAssertNotNil(message)
        XCTAssertEqual(message?.id, "msg001")
        XCTAssertEqual(message?.dateLine, "New Request")
        XCTAssertEqual(message?.type, "request_received")
        XCTAssertEqual(message?.showsRejectButton, true)
        XCTAssertEqual(message?.timestamp, timestamp)
        XCTAssertEqual(message?.isRead, false)
        XCTAssertEqual(message?.relatedTransactionId, "txn789")
        XCTAssertEqual(message?.lenderName, "John Doe")
        XCTAssertEqual(message?.itemName, "Hammer")
    }

    func testInboxMessageInitializationWithDictionary_MissingFields() {
        let messageDict: [String: Any] = [
            "dateLine": "New Request",
            // "type" is missing
            "showsRejectButton": true,
            "timestamp": Date().timeIntervalSince1970
        ]
        let message = InboxMessage(id: "msg002", dictionary: messageDict)
        XCTAssertNil(message, "Message should be nil if essential fields are missing.")
    }
    
    func testInboxMessageToDictionary() {
        let timestamp = Date().timeIntervalSince1970
        let message = InboxMessage(
            id: "msg003",
            dateLine: "Update",
            type: "general_info",
            showsRejectButton: false,
            relatedTransactionId: nil,
            timestamp: timestamp,
            isRead: true,
            lenderName: nil,
            itemName: "Wrench"
        )

        let dict = message.toDictionary()

        XCTAssertEqual(dict["id"] as? String, "msg003")
        XCTAssertEqual(dict["dateLine"] as? String, "Update")
        XCTAssertEqual(dict["type"] as? String, "general_info")
        XCTAssertEqual(dict["showsRejectButton"] as? Bool, false)
        XCTAssertTrue(dict["relatedTransactionId"] is NSNull)
        XCTAssertEqual(dict["timestamp"] as? TimeInterval, timestamp)
        XCTAssertEqual(dict["isRead"] as? Bool, true)
        XCTAssertTrue(dict["lenderName"] is NSNull)
        XCTAssertEqual(dict["itemName"] as? String, "Wrench")
    }


    func testTransactionInitializationAndToDictionary() {
        let transaction = Transaction(
            id: "txn123",
            transactionDate: "2025-06-01T10:00:00Z",
            startTime: "2025-06-05T14:00:00Z",
            endTime: "2025-06-10T18:00:00Z",
            relatedItemId: "itemXYZ",
            ownerId: "owner1",
            borrowerId: "borrower2",
            requestStatus: "pending"
        )

        XCTAssertEqual(transaction.id, "txn123")
        XCTAssertEqual(transaction.requestStatus, "pending")

        let dict = transaction.toDictionary()
        XCTAssertEqual(dict["id"] as? String, "txn123")
        XCTAssertEqual(dict["transactionDate"] as? String, "2025-06-01T10:00:00Z")
        XCTAssertEqual(dict["startTime"] as? String, "2025-06-05T14:00:00Z")
        XCTAssertEqual(dict["endTime"] as? String, "2025-06-10T18:00:00Z")
        XCTAssertEqual(dict["relatedItemId"] as? String, "itemXYZ")
        XCTAssertEqual(dict["ownerId"] as? String, "owner1")
        XCTAssertEqual(dict["borrowerId"] as? String, "borrower2")
        XCTAssertEqual(dict["requestStatus"] as? String, "pending")
    }
    
    func testTransactionRequestStatusDefault() {
        // Test that requestStatus defaults to "pending"
        let transaction = Transaction(
            id: "txnDefault",
            transactionDate: "2025-06-01T10:00:00Z",
            startTime: "2025-06-05T14:00:00Z",
            endTime: "2025-06-10T18:00:00Z",
            relatedItemId: "itemDefault",
            ownerId: "ownerDefault",
            borrowerId: "borrowerDefault"
            // requestStatus is omitted
        )
        XCTAssertEqual(transaction.requestStatus, "pending")
    }


    func testUserSessionInitialization() {
        let session = UserSession(uid: "uid123", email: "test@example.com", displayName: "Test User")
        XCTAssertEqual(session.uid, "uid123")
        XCTAssertEqual(session.email, "test@example.com")
        XCTAssertEqual(session.displayName, "Test User")
    }
    
    func testUserSessionDisplayNameIsOptional() {
        let session = UserSession(uid: "uid456", email: "another@example.com", displayName: nil)
        XCTAssertEqual(session.uid, "uid456")
        XCTAssertEqual(session.email, "another@example.com")
        XCTAssertNil(session.displayName)
        
        var mutableSession = session
        mutableSession.displayName = "Updated Name"
        XCTAssertEqual(mutableSession.displayName, "Updated Name")
    }
}
