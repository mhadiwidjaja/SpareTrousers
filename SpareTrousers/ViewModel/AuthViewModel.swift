//
//  AuthViewModel.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var userSession: UserSession? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.userSession = UserSession(uid: user.uid, email: user.email)
        } else {
            self.userSession = nil
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let user = result?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email)
                }
            }
        }
    }

    func register(email: String, password: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let user = result?.user {
                    self.userSession = UserSession(uid: user.uid, email: user.email)
                }
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
}
