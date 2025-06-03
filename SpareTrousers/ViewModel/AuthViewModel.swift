//
//  AuthViewModel.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import FirebaseAuth
import Combine
import FirebaseDatabase



//class AuthViewModel: ObservableObject {
//    @Published var userSession: UserSession? = nil
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var userAddress: String? = nil // To store the fetched address
//
//    // Reference to Firebase Realtime Database
//    private var ref: DatabaseReference!
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        ref = Database.database().reference() // Initialize database reference
//        checkAuthState()
//
//        // Observe userSession changes to fetch address when user logs in
//        $userSession
//            .compactMap { $0?.uid } // Get UID if userSession is not nil
//            .flatMap { [weak self] uid -> AnyPublisher<String?, Never> in
//                self?.fetchUserAddress(uid: uid) ?? Just(nil).eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.userAddress, on: self)
//            .store(in: &cancellables)
//        
//        // Clear address on logout
//        $userSession
//            .filter { $0 == nil }
//            .sink { [weak self] _ in
//                self?.userAddress = nil
//            }
//            .store(in: &cancellables)
//    }
//
//    func checkAuthState() {
//        if let user = Auth.auth().currentUser {
//            self.userSession = UserSession(uid: user.uid, email: user.email)
//            // No need to call fetchUserAddress here explicitly due to the publisher above
//        } else {
//            self.userSession = nil
//            self.userAddress = nil // Clear address if no user
//        }
//    }
//
//    func login(email: String, password: String) {
//        isLoading = true
//        errorMessage = nil
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if let error = error {
//                    self.errorMessage = error.localizedDescription
//                    return
//                }
//                if let user = result?.user {
//                    self.userSession = UserSession(uid: user.uid, email: user.email)
//                    // Address will be fetched by the publisher observing userSession
//                }
//            }
//        }
//    }
//
//    // Updated register function to include address
//    func register(email: String, password: String, address: String) {
//        isLoading = true
//        errorMessage = nil
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if let error = error {
//                    self.errorMessage = error.localizedDescription
//                    return
//                }
//                if let user = authResult?.user {
//                    self.userSession = UserSession(uid: user.uid, email: user.email)
//                    // Save user details (including address) to Realtime Database
//                    self.saveUserDetails(uid: user.uid, email: email, address: address)
//                }
//            }
//        }
//    }
//
//    // Function to save user details to Firebase Realtime Database
//    private func saveUserDetails(uid: String, email: String, address: String) {
//        let userData: [String: Any] = [
//            "email": email,
//            "address": address
//            // Add any other user details you want to save
//        ]
//        // Save under a "users" node, with each user identified by their UID
//        self.ref.child("users").child(uid).setValue(userData) { error, _ in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Failed to save user details: \(error.localizedDescription)"
//                }
//            } else {
//                print("User details saved successfully.")
//                // Optionally, update local userAddress immediately if desired,
//                // though the fetch mechanism should also pick it up.
//                DispatchQueue.main.async {
//                    self.userAddress = address
//                }
//            }
//        }
//    }
//
//    // Function to fetch user address from Firebase Realtime Database
//    // This now returns a publisher for better integration
//    func fetchUserAddress(uid: String) -> AnyPublisher<String?, Never> {
//        let future = Future<String?, Never> { [weak self] promise in
//            guard let self = self else {
//                promise(.success(nil))
//                return
//            }
//            self.ref.child("users").child(uid).child("address").observeSingleEvent(of: .value) { snapshot in
//                if let address = snapshot.value as? String {
//                    promise(.success(address))
//                } else {
//                    print("Address not found or not a string for UID: \(uid)")
//                    promise(.success(nil)) // Address not found or not a string
//                }
//            } withCancel: { error in
//                print("Failed to fetch address: \(error.localizedDescription)")
//                promise(.success(nil)) // Error fetching
//            }
//        }
//        return future.eraseToAnyPublisher()
//    }
//
//
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//            DispatchQueue.main.async {
//                self.userSession = nil
//                self.userAddress = nil // Clear address on logout
//                self.errorMessage = nil
//            }
//        } catch let signOutError as NSError {
//            DispatchQueue.main.async {
//                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
//            }
//        }
//    }
//}

class AuthViewModel: ObservableObject {
    @Published var userSession: UserSession? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userAddress: String? = nil
    // No need to separately publish displayName if it's part of UserSession
    // @Published var userDisplayName: String? = nil // This can be removed

    private var ref: DatabaseReference!
    private var cancellables = Set<AnyCancellable>()

    init() {
        ref = Database.database().reference()
        checkAuthState() // This will now also attempt to get displayName

        // Observe userSession changes to fetch additional details if needed
        $userSession
            .compactMap { $0?.uid }
            .flatMap { [weak self] uid -> AnyPublisher<(address: String?, displayName: String?), Never> in
                guard let self = self else {
                    return Just((nil, nil)).eraseToAnyPublisher()
                }
                // Combine fetching address and display name
                let addressPublisher = self.fetchUserAddress(uid: uid)
                let displayNamePublisher = self.fetchUserDisplayName(uid: uid)
                
                return Publishers.Zip(addressPublisher, displayNamePublisher)
                    .map { (address: $0.0, displayName: $0.1) } // Keep tuple structure
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (fetchedAddress, fetchedDisplayName) in
                guard let self = self else { return }
                self.userAddress = fetchedAddress
                // Update displayName in userSession if it was fetched and not already set
                if self.userSession?.displayName == nil, let name = fetchedDisplayName {
                    self.userSession?.displayName = name
                }
            }
            .store(in: &cancellables)
        
        $userSession
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.userAddress = nil
                // userDisplayName = nil // No longer needed
            }
            .store(in: &cancellables)
    }

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            // Initialize UserSession with displayName from Firebase Auth if available
            self.userSession = UserSession(uid: user.uid, email: user.email, displayName: user.displayName)
            // If user.displayName is nil, the publisher above will try to fetch it from DB
        } else {
            self.userSession = nil
            self.userAddress = nil
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription; return
                }
                if let user = result?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email, displayName: user.displayName)
                    // Additional details like address and potentially displayName (if not in Auth)
                    // will be fetched by the publisher observing userSession.
                }
            }
        }
    }

    // Updated register function to include displayName (and address)
    func register(email: String, password: String, displayName: String, address: String) {
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            if let user = authResult?.user {
                // Set display name in Firebase Authentication profile
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false // Set loading to false after all operations
                        if let error = error {
                            self.errorMessage = "Failed to set display name: \(error.localizedDescription)"
                            // User is created, but display name update failed.
                            // Still proceed to save other details and set session.
                        }
                        // Update userSession with the new user, including the intended displayName
                        self.userSession = UserSession(uid: user.uid, email: user.email, displayName: displayName)
                        // Save user details (email, address, displayName) to Realtime Database
                        self.saveUserDetails(uid: user.uid, email: email, displayName: displayName, address: address)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "User creation succeeded but user object is nil."
                }
            }
        }
    }

    // Updated to save displayName
    private func saveUserDetails(uid: String, email: String, displayName: String, address: String) {
        let userData: [String: Any] = [
            "email": email,
            "displayName": displayName, // Save displayName
            "address": address
        ]
        self.ref.child("users").child(uid).setValue(userData) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to save user details: \(error.localizedDescription)"
                } else {
                    print("User details (including displayName and address) saved successfully.")
                    // Update local state if needed, though publishers should handle it
                    self?.userAddress = address
                    // If userSession was set before displayName was confirmed from DB:
                    if self?.userSession?.uid == uid {
                         self?.userSession?.displayName = displayName
                    }
                }
            }
        }
    }
    
    // Function to fetch user displayName from Firebase Realtime Database
    func fetchUserDisplayName(uid: String) -> AnyPublisher<String?, Never> {
        Future<String?, Never> { [weak self] promise in
            guard let self = self else { promise(.success(nil)); return }
            self.ref.child("users").child(uid).child("displayName").observeSingleEvent(of: .value) { snapshot in
                promise(.success(snapshot.value as? String))
            } withCancel: { error in
                print("Failed to fetch displayName: \(error.localizedDescription)")
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchUserAddress(uid: String) -> AnyPublisher<String?, Never> {
        Future<String?, Never> { [weak self] promise in
            guard let self = self else { promise(.success(nil)); return }
            self.ref.child("users").child(uid).child("address").observeSingleEvent(of: .value) { snapshot in
                promise(.success(snapshot.value as? String))
            } withCancel: { error in
                print("Failed to fetch address: \(error.localizedDescription)")
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userSession = nil
                self.userAddress = nil
                self.errorMessage = nil
            }
        } catch let signOutError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }
}
