//
//  LoginRegisterView.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct LoginRegisterView: View {

    @ObservedObject var viewModel: AuthViewModel
    
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var showingRegister = false

    // Local state for displaying temporary messages
    @State private var feedbackMessage: String? = nil
    @State private var isErrorFeedback: Bool = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) { // Main Card
                // Blue Header
                VStack(spacing: 16) { /* ... Header content ... */
                    Spacer().frame(height: 24)
                    ZStack {
                        Color.appBlue
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        Image("SpareTrousers")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    VStack(spacing: -8) {
                        Text("Welcome to")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                        Text("Spare Trousers")
                            .font(.custom("MarkerFelt-Wide", size: 40))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                    }
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(Color.appBlue)

                // Orange Form
                VStack(spacing: 16) {
                    TextField("Enter email", text: $loginEmail)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appBlack, lineWidth: 2)
                        )
                        .autocapitalization(.none).keyboardType(.emailAddress)

                    SecureField("Enter password", text: $loginPassword)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appBlack, lineWidth: 2)
                        )

                    // Feedback Message Area
                    if let message = feedbackMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(isErrorFeedback ? .red : .green)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.isLoading { // Show "Logging in..." only if no other message
                        Text("Logging in...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 5)
                    }


                    HStack {
                        Spacer()
                        Text("New User?")
                        Button("Register") {
                            clearFeedback()
                            showingRegister = true
                        }
                        .foregroundColor(.appBlue)
                    }

                    Button {
                        clearFeedback()
                        viewModel
                            .login(email: loginEmail, password: loginPassword)
                    } label: {
                        if viewModel.isLoading && feedbackMessage == nil { // Show ProgressView only if no specific feedback
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                                .frame(maxWidth: .infinity).frame(height: 66)
                        } else {
                            Text("LOGIN")
                                .font(.custom("MarkerFelt-Wide", size: 48))
                                .shadow(color: .appBlack, radius: 1)
                                .frame(maxWidth: .infinity).frame(height: 66)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .background(Color.appBlue)
                    .foregroundColor(.appWhite)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.appOrange)
            }
            .background(Color.appWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBlack, lineWidth: 4)
            )
            .padding(24)

            Spacer()
        }
        .sheet(isPresented: $showingRegister) {
            RegisterCard(viewModel: viewModel) // Pass the same viewModel
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.errorMessage) { newError in
            if let error = newError {
                self.feedbackMessage = "Login failed: \(error)"
                self.isErrorFeedback = true
            }
        }
        .onChange(of: viewModel.successMessage) { newSuccess in
            if let success = newSuccess, viewModel.userSession != nil { // Only show success if session is also set
                self.feedbackMessage = success // e.g., "Login Successful!"
                self.isErrorFeedback = false
                // Message will clear due to ViewModel or automatically due to navigation
            }
        }
        // Navigation to HomeView is handled by SpareTrousersApp based on userSession
    }
    
    private func clearFeedback() {
        feedbackMessage = nil
        viewModel.errorMessage = nil // Also clear error in ViewModel if re-attempting
        viewModel.successMessage = nil
    }
}

struct RegisterCard: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var displayName = "" // Added for display name
    @State private var address = ""

    // Local state for displaying temporary messages in RegisterCard
    @State private var feedbackMessage: String? = nil
    @State private var isErrorFeedback: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(spacing: 0) { // Main Card
                    RegisterHeader()
                    RegisterForm(
                        email: $email,
                        password: $password,
                        displayName: $displayName, // Pass binding
                        address: $address,
                        viewModel: viewModel,
                        feedbackMessage: $feedbackMessage, // Pass binding for feedback
                        isErrorFeedback: $isErrorFeedback, // Pass binding
                        onDismiss: { dismiss() }
                    )
                }
                .background(Color.appWhite)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appBlack, lineWidth: 4)
                )
                .padding(24)
                Spacer()
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.errorMessage) { newError in
                if let error = newError {
                    self.feedbackMessage = "Registration Failed: \(error)"
                    self.isErrorFeedback = true
                }
            }
            .onChange(of: viewModel.successMessage) { newSuccess in
                if let success = newSuccess, viewModel.userSession != nil {
                    self.feedbackMessage = success // e.g., "Registration Successful!"
                    self.isErrorFeedback = false
                    // Dismiss after a short delay to show the message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if viewModel.userSession != nil { // Double check session before dismissing
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
    
private struct RegisterHeader: View {
    var body: some View {
        VStack(spacing: 16) { /* ... Header content ... */
            Spacer().frame(height: 24)
            Image("SpareTrousers")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            VStack(spacing: -8) {
                Text("Create Account")
                    .font(.custom("MarkerFelt-Wide", size: 24))
                    .foregroundColor(.appWhite)
                    .shadow(color: .appBlack, radius: 1)
                Text("Spare Trousers")
                    .font(.custom("MarkerFelt-Wide", size: 40))
                    .foregroundColor(.appWhite)
                    .shadow(color: .appBlack, radius: 1)
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Color.appBlue)
    }
}

private struct RegisterForm: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var displayName: String // Added for display name
    @Binding var address: String
    @ObservedObject var viewModel: AuthViewModel
    @Binding var feedbackMessage: String? // To display feedback
    @Binding var isErrorFeedback: Bool // To style feedback

    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter email", text: $email)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color.appWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appBlack, lineWidth: 2)
                )
                .autocapitalization(.none).keyboardType(.emailAddress)

            // Display Name Field
            TextField("Enter display name", text: $displayName)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color.appWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appBlack, lineWidth: 2)
                )
                .autocapitalization(.words)

            SecureField("Enter password", text: $password)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color.appWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appBlack, lineWidth: 2)
                )

            TextField("Enter address", text: $address)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color.appWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appBlack, lineWidth: 2)
                )
                .autocapitalization(.words)

            // Feedback Message Area
            if let message = feedbackMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(isErrorFeedback ? .red : .green)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.isLoading {
                Text("Registering...")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)
            }

            HStack {
                Spacer()
                Text("Have an account?")
                Button("Login") {
                    feedbackMessage = nil // Clear feedback when switching
                    viewModel.errorMessage = nil
                    viewModel.successMessage = nil
                    onDismiss()
                }
                .foregroundColor(.appBlue)
            }

            Button {
                feedbackMessage = nil // Clear previous feedback
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
                viewModel.register(
                    email: email, password: password,
                    displayName: displayName, // Pass display name
                    address: address
                )
                // Dismissal is handled by onChange of successMessage in RegisterCard
            } label: {
                if viewModel.isLoading && feedbackMessage == nil {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .frame(maxWidth: .infinity).frame(height: 66)
                } else {
                    Text("REGISTER")
                        .font(.custom("MarkerFelt-Wide", size: 48))
                        .shadow(color: .appBlack, radius: 1)
                        .frame(maxWidth: .infinity).frame(height: 66)
                }
            }
            .disabled(viewModel.isLoading)
            .background(Color.appBlue)
            .foregroundColor(.appWhite)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity).padding(20).background(Color.appOrange)
    }
}

// MARK: - Preview
struct LoginRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure AuthViewModel is passed if LoginRegisterView expects it as @ObservedObject
        LoginRegisterView(viewModel: AuthViewModel())
    }
}
