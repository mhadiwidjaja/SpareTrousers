//
//  WatchLoginView.swift
//  SpareTrousers
//
//  Created by student on 05/06/25.
//


import SwiftUI

struct WatchLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    @State private var showingLoginErrorAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image("SpareTrousers")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 8)

                Text("Log In")
                    .font(.headline)
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .disableAutocorrection(true)
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)


                // Password SecureField
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                if authViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 5)
                } else if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .onAppear {
                            if !errorMessage.isEmpty {
                                showingLoginErrorAlert = true
                            }
                        }
                }

                // Login Button
                Button(action: performLogin) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.orange)
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Login")
        .alert("Login Failed", isPresented: $showingLoginErrorAlert) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "An unknown error occurred.")
        }
    }

    // Function to call the login method on the AuthViewModel
    private func performLogin() {
        authViewModel.errorMessage = nil
        showingLoginErrorAlert = false

        authViewModel.login(email: email, password: password)
    }
}

// Preview Provider for WatchLoginView
struct WatchLoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthViewModel = AuthViewModel()

        return NavigationView {
            WatchLoginView()
                .environmentObject(mockAuthViewModel)
        }
    }
}
