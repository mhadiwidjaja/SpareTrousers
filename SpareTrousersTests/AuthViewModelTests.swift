//
//  AuthViewModelTests.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import XCTest
import Combine
@testable import SpareTrousers

class MockAuth {
    var currentUser: MockUser?
    var signInShouldSucceed: Bool = true
    var signInError: Error? = TestError.generic
    var createUserShouldSucceed: Bool = true
    var createUserError: Error? = TestError.generic
    var signOutShouldSucceed: Bool = true
    var signOutError: Error? = TestError.generic

    func signIn(withEmail email: String, password: String, completion: @escaping (MockAuthDataResult?, Error?) -> Void) {
        if signInShouldSucceed {
            self.currentUser = MockUser(uid: "testUID", email: email, displayName: "Test User")
            completion(MockAuthDataResult(user: self.currentUser!), nil)
        } else {
            completion(nil, signInError)
        }
    }

    func createUser(withEmail email: String, password: String, completion: @escaping (MockAuthDataResult?, Error?) -> Void) {
        if createUserShouldSucceed {
             self.currentUser = MockUser(uid: "newUID", email: email, displayName: nil)
            completion(MockAuthDataResult(user: self.currentUser!), nil)
        } else {
            completion(nil, createUserError)
        }
    }
    
    func signOut() throws {
        if !signOutShouldSucceed {
            throw signOutError ?? TestError.generic
        }
        currentUser = nil
    }
    
}

struct MockAuthDataResult {
    let user: MockUser
}

struct MockUser {
    let uid: String
    let email: String?
    var displayName: String?
    func createProfileChangeRequest() -> MockProfileChangeRequest {
        return MockProfileChangeRequest(user: self)
    }
}
struct MockProfileChangeRequest {
    var user: MockUser
    var displayName: String?
    func commitChanges(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}

class MockDatabaseReference {
    var dbData: [String: Any] = [:]
    var shouldSetValueSucceed: Bool = true
    var observeSingleEventShouldSucceed: Bool = true
    var observeError: Error? = TestError.generic

    func child(_ path: String) -> MockDatabaseReference {
        return self
    }

    func setValue(_ value: Any?, completion: @escaping (Error?, MockDatabaseReference?) -> Void) {
        if shouldSetValueSucceed {
            if let path = currentPathForMock {
                var currentLevel = dbData
                let components = path.split(separator: "/")
                for (index, component) in components.enumerated() {
                    if index == components.count - 1 {
                        currentLevel[String(component)] = value
                    } else {
                        if currentLevel[String(component)] == nil {
                            currentLevel[String(component)] = [String: Any]()
                        }
                    }
                }
                 dbData = currentLevel
            }
            completion(nil, self)
        } else {
            completion(TestError.generic, nil)
        }
    }
    
    var currentPathForMock: String?
    
    func observeSingleEvent(of eventType: MockDataEventType, with block: @escaping (MockDataSnapshot) -> Void, withCancel cancelBlock: ((Error) -> Void)? = nil) {
        if observeSingleEventShouldSucceed {
            let snapshot = MockDataSnapshot(value: dbData[currentPathForMock ?? ""])
            block(snapshot)
        } else {
            cancelBlock?(observeError ?? TestError.generic)
        }
    }
}
enum MockDataEventType { case value }
struct MockDataSnapshot { var value: Any? }


enum TestError: Error {
    case generic
    case networkError
}


class AuthViewModelTests: XCTestCase {

    var viewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        viewModel = AuthViewModel()
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(viewModel.userSession)
        XCTAssertNil(viewModel.userAddress)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUserAddressClearsOnLogout() {
        // Simulate a logged-in state where userSession and userAddress are set
        viewModel.userSession = UserSession(uid: "testUID", email: "test@example.com", displayName: "Test User")
        viewModel.userAddress = "123 Main St"
        XCTAssertNotNil(viewModel.userSession, "Pre-condition: userSession should be set.")
        XCTAssertNotNil(viewModel.userAddress, "Pre-condition: userAddress should be set.")

        // Create an expectation for userAddress becoming nil
        let addressExpectation = XCTestExpectation(description: "userAddress becomes nil")
        viewModel.$userAddress
            .dropFirst()
            .filter { $0 == nil }
            .sink { _ in
                addressExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Simulate logout by setting userSession to nil (as the `logout()` method would do)
        // This triggers the sink in the AuthViewModel's init that clears userAddress.
        viewModel.userSession = nil
        
        wait(for: [addressExpectation], timeout: 1.0)
        
        XCTAssertNil(viewModel.userAddress, "userAddress should be nil after userSession is nilled.")
    }
}
