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
    @Published var userAddress: String? = nil // To store the fetched address

    // Reference to Firebase Realtime Database
    private var ref: DatabaseReference!

    private var cancellables = Set<AnyCancellable>()

    init() {
        ref = Database.database().reference() // Initialize database reference
        checkAuthState()

        // Observe userSession changes to fetch address when user logs in
        $userSession
            .compactMap { $0?.uid } // Get UID if userSession is not nil
            .flatMap { [weak self] uid -> AnyPublisher<String?, Never> in
                self?.fetchUserAddress(uid: uid) ?? Just(nil).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.userAddress, on: self)
            .store(in: &cancellables)
        
        // Clear address on logout
        $userSession
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.userAddress = nil
            }
            .store(in: &cancellables)
    }

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.userSession = UserSession(uid: user.uid, email: user.email)
            // No need to call fetchUserAddress here explicitly due to the publisher above
        } else {
            self.userSession = nil
            self.userAddress = nil // Clear address if no user
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
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let user = result?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email)
                    // Address will be fetched by the publisher observing userSession
                }
            }
        }
    }

    // Updated register function to include address
    func register(email: String, password: String, address: String) {
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let user = authResult?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email)
                    // Save user details (including address) to Realtime Database
                    self.saveUserDetails(uid: user.uid, email: email, address: address)
                }
            }
        }
    }

    // Function to save user details to Firebase Realtime Database
    private func saveUserDetails(uid: String, email: String, address: String) {
        let userData: [String: Any] = [
            "email": email,
            "address": address
            // Add any other user details you want to save
        ]
        // Save under a "users" node, with each user identified by their UID
        self.ref.child("users").child(uid).setValue(userData) { error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save user details: \(error.localizedDescription)"
                }
            } else {
                print("User details saved successfully.")
                // Optionally, update local userAddress immediately if desired,
                // though the fetch mechanism should also pick it up.
                DispatchQueue.main.async {
                    self.userAddress = address
                }
            }
        }
    }

    // Function to fetch user address from Firebase Realtime Database
    // This now returns a publisher for better integration
    func fetchUserAddress(uid: String) -> AnyPublisher<String?, Never> {
        let future = Future<String?, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(nil))
                return
            }
            self.ref.child("users").child(uid).child("address").observeSingleEvent(of: .value) { snapshot in
                if let address = snapshot.value as? String {
                    promise(.success(address))
                } else {
                    print("Address not found or not a string for UID: \(uid)")
                    promise(.success(nil)) // Address not found or not a string
                }
            } withCancel: { error in
                print("Failed to fetch address: \(error.localizedDescription)")
                promise(.success(nil)) // Error fetching
            }
        }
        return future.eraseToAnyPublisher()
    }


    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userSession = nil
                self.userAddress = nil
                self.errorMessage = nil
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }
    
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
}
