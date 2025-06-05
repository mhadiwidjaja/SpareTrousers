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
    @Published var successMessage: String? = nil // Added for explicit success messages
    @Published var errorMessage: String?
    @Published var userAddress: String? = nil

    private var ref: DatabaseReference!
    private var cancellables = Set<AnyCancellable>()

    init() {
        ref = Database.database().reference()
        checkAuthState()

        $userSession
            .compactMap { $0?.uid }
            .flatMap { [weak self] uid -> AnyPublisher<(address: String?, displayName: String?), Never> in
                guard let self = self else { return Just((nil, nil)).eraseToAnyPublisher() }
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
        
        $userSession
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.userAddress = nil
            }
            .store(in: &cancellables)
    }

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.userSession = UserSession(uid: user.uid, email: user.email, displayName: user.displayName)
        } else {
            self.userSession = nil; self.userAddress = nil
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil // Clear previous errors
        successMessage = nil // Clear previous success messages
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let user = result?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email, displayName: user.displayName)
                    self.successMessage = "Login Successful!" // Navigation will happen due to userSession change
                    // Clear message after a delay if not navigating immediately
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.successMessage = nil }
                }
            }
        }
    }

    func register(email: String, password: String, displayName: String, address: String) {
        isLoading = true
        errorMessage = nil // Clear previous errors
        successMessage = nil // Clear previous success messages

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false; self.errorMessage = error.localizedDescription
                }
                return
            }
            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { [weak self] error in
                    guard let self = self else { return }
                    // isLoading should be set to false after all operations (including DB save)
                    // For now, setting it after display name commit or its error.
                    if let error = error {
                        DispatchQueue.main.async {
                            // Still proceed to save other details even if display name auth update fails
                            // But show this as a specific error, maybe non-fatal.
                            self.errorMessage = "User created, but failed to set display name on Auth: \(error.localizedDescription)"
                            // Set userSession and save other details
                            self.userSession = UserSession(uid: user.uid, email: user.email, displayName: displayName) // Use intended displayName
                            self.saveUserDetails(uid: user.uid, email: email, displayName: displayName, address: address) { success in
                                self.isLoading = false // Final loading state update
                                if success {
                                     self.successMessage = "Registration Successful (with display name note)!"
                                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.successMessage = nil }
                                }
                                // Error from saveUserDetails will set self.errorMessage
                            }
                        }
                        return
                    }
                    // Display name on Auth successful, now save all details
                    self.userSession = UserSession(uid: user.uid, email: user.email, displayName: displayName)
                    self.saveUserDetails(uid: user.uid, email: email, displayName: displayName, address: address) { success in
                        self.isLoading = false // Final loading state update
                        if success {
                            self.successMessage = "Registration Successful!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.successMessage = nil }
                        }
                        // Error from saveUserDetails will set self.errorMessage
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

    // Modified saveUserDetails to include a completion handler for success/failure of this specific step
    private func saveUserDetails(uid: String, email: String, displayName: String, address: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "email": email, "displayName": displayName, "address": address
        ]
        self.ref.child("users").child(uid).setValue(userData) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to save user details: \(error.localizedDescription)"
                    completion(false)
                } else {
                    print("User details saved successfully.")
                    self?.userAddress = address
                    if self?.userSession?.uid == uid { self?.userSession?.displayName = displayName }
                    completion(true)
                }
            }
        }
    }
    
    // ... (fetchUserDisplayName, fetchUserAddress, logout, updateUserAddress, updateUserDisplayName remain the same) ...
    func fetchUserDisplayName(uid: String) -> AnyPublisher<String?, Never> {
        Future<String?, Never> { [weak self] promise in
            guard let self = self else { promise(.success(nil)); return }
            self.ref.child("users").child(uid).child("displayName").observeSingleEvent(of: .value) { snapshot in
                promise(.success(snapshot.value as? String))
            } withCancel: { error in
                print("Failed to fetch displayName: \(error.localizedDescription)"); promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }
    func fetchUserAddress(uid: String) -> AnyPublisher<String?, Never> {
        Future<String?, Never> { [weak self] promise in
            guard let self = self else { promise(.success(nil)); return }
            self.ref.child("users").child(uid).child("address").observeSingleEvent(of: .value) { snapshot in
                promise(.success(snapshot.value as? String))
            } withCancel: { error in
                print("Failed to fetch address: \(error.localizedDescription)"); promise(.success(nil))
            }
        }.eraseToAnyPublisher()
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
