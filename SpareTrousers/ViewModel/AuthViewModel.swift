//
//  AuthViewModel.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import FirebaseAuth
import Combine
import FirebaseDatabase

class AuthViewModel: ObservableObject {
    @Published var userSession: UserSession? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userAddress: String? = nil

    private var ref: DatabaseReference!
    private var cancellables = Set<AnyCancellable>()

    // Initializes the AuthViewModel
    init() {
        ref = Database.database().reference()
        checkAuthState()

        // Publisher pipeline to fetch user address and display name when UID is available
        $userSession
            .compactMap { $0?.uid }
            .flatMap { [weak self] uid -> AnyPublisher<(address: String?, displayName: String?), Never> in
                guard let self = self else {
                    return Just((nil, nil)).eraseToAnyPublisher()
                }
                let addressPublisher = self.fetchUserAddress(uid: uid)
                let displayNamePublisher = self.fetchUserDisplayName(uid: uid)
                
                return Publishers.Zip(addressPublisher, displayNamePublisher)
                    .map { (address: $0.0, displayName: $0.1) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (fetchedAddress, fetchedDisplayName) in
                guard let self = self else { return }
                self.userAddress = fetchedAddress
                if self.userSession?.displayName == nil, let name = fetchedDisplayName {
                    self.userSession?.displayName = name
                }
            }
            .store(in: &cancellables)
        
        // Publisher to clear userAddress when userSession becomes nil
        $userSession
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.userAddress = nil
            }
            .store(in: &cancellables)
    }

    // Checks the current Firebase authentication state.
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.userSession = UserSession(uid: user.uid, email: user.email, displayName: user.displayName)
        } else {
            self.userSession = nil
            self.userAddress = nil
        }
    }

    // Handles user login with email and password.
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
                }
            }
        }
    }

    // Handles user registration with email, password, display name, and address.
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
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = "Failed to set display name: \(error.localizedDescription)"
                        }
                        self.userSession = UserSession(uid: user.uid, email: user.email, displayName: displayName)
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

    // Saves user details to Firebase Realtime Database.
    private func saveUserDetails(uid: String, email: String, displayName: String, address: String) {
        let userData: [String: Any] = [
            "email": email,
            "displayName": displayName,
            "address": address
        ]
        self.ref.child("users").child(uid).setValue(userData) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to save user details: \(error.localizedDescription)"
                } else {
                    print("User details (including displayName and address) saved successfully.")
                    self?.userAddress = address
                    if self?.userSession?.uid == uid {
                         self?.userSession?.displayName = displayName
                    }
                }
            }
        }
    }
    
    // Fetches user display name from Firebase Realtime Database.
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

    // Fetches user address from Firebase Realtime Database.
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

    // Logs out the current user.
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
    
    // Updates the user's address in Firebase Realtime Database.
    func updateUserAddress(newAddress: String) {
        guard let uid = self.userSession?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in. Cannot update address."
                print(self.errorMessage ?? "Error: User not logged in for address update.")
            }
            return
        }
        
        let userAddressRef = ref.child("users").child(uid).child("address")
        
        userAddressRef.setValue(newAddress) { [weak self] error, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to update address: \(error.localizedDescription)"
                    print(self.errorMessage ?? "Error: Failed to update address in Firebase.")
                } else {
                    print("User address updated successfully in Firebase.")
                    self.userAddress = newAddress
                    self.errorMessage = nil
                }
            }
        }
    }
    
    // Updates the user's display name in Firebase Authentication and Realtime Database.
    func updateUserDisplayName(newName: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, "No authenticated user found.")
            return
        }

        // Update Firebase Authentication display name
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(false, "Error updating Auth profile: \(error.localizedDescription)")
                return
            }

            // Update display name in Realtime Database
            let dbRef = Database.database().reference()
            dbRef.child("users").child(user.uid).child("displayName").setValue(newName) { error, _ in
                if let error = error {
                    completion(false, "Error updating Realtime Database: \(error.localizedDescription)")
                    return
                }

                // Update local userSession
                DispatchQueue.main.async {
                    self.userSession?.displayName = newName
                    completion(true, nil)
                }
            }
        }
    }
}
