//
//  LoginRegisterView.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import SwiftUI




struct LoginRegisterView: View {
    // Use @StateObject if LoginRegisterView is the source of truth for AuthViewModel
    // or @ObservedObject if it's passed from a parent that owns it.
    // For the preview and typical app structure, @StateObject is often suitable here if this is a root view for auth.
    @StateObject var viewModel: AuthViewModel // Changed to @StateObject if it's the owner
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var showingRegister = false

    var body: some View {
        VStack {
            Spacer()

            // ───── Card VStack ─────
            VStack(spacing: 0) {
                // Blue Header
                VStack(spacing: 16) {
                    Spacer().frame(height: 24)

                    ZStack {
                        Color.appBlue
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        Image("SpareTrousers") // Ensure this image is in your assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }

                    VStack(spacing: -8) {
                        Text("Welcome to")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                        Text("Spare Trousers")
                            .font(.custom("MarkerFelt-Wide", size: 40))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
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
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Enter password", text: $loginPassword)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appBlack, lineWidth: 2)
                        )

                    HStack {
                        Spacer()
                        Text("New User?")
                        Button("Register") { showingRegister = true }
                            .foregroundColor(.appBlue)
                    }

                    Button {
                        viewModel
                            .login(email: loginEmail, password: loginPassword)
                    } label: {
                        Text("LOGIN")
                            .font(.custom("MarkerFelt-Wide", size: 48))
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(Color.appBlue)
                            .foregroundColor(.appWhite)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.appOrange)
            }
            .background(Color.appWhite)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBlack, lineWidth: 4)
            )
            .padding(24)

            Spacer()
        }
        .sheet(isPresented: $showingRegister) {
            // Pass the same AuthViewModel instance to RegisterCard
            RegisterCard(viewModel: viewModel)
        }
        // If LoginRegisterView is a root view for authentication,
        // it might be where AuthViewModel is initialized.
        // .environmentObject(viewModel) // If sub-sub-views need it via environment
    }
}

struct RegisterCard: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var address = "" // New state for address

    var body: some View {
        // Wrap in NavigationView to allow for a potential title and cleaner presentation
        NavigationView {
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 24)
                        Image("SpareTrousers") // Ensure this image is in your assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        VStack(spacing: -8) {
                            Text("Create Account") // Changed title for clarity
                                .font(.custom("MarkerFelt-Wide", size: 24))
                                .foregroundColor(.appWhite)
                                .shadow(color: .appBlack, radius: 1) // Apply shadows as needed
                            Text("Spare Trousers")
                                .font(.custom("MarkerFelt-Wide", size: 40))
                                .foregroundColor(.appWhite)
                                .shadow(color: .appBlack, radius: 1)
                        }
                    }
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.appBlue)

                    VStack(spacing: 16) {
                        TextField("Enter email", text: $email)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.appWhite)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBlack, lineWidth: 2))
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Enter password", text: $password)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.appWhite)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBlack, lineWidth: 2))

                        // New TextField for Address
                        TextField("Enter address", text: $address)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.appWhite)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBlack, lineWidth: 2))
                            .autocapitalization(.words)


                        HStack {
                            Spacer()
                            Text("Have an account?")
                            Button("Login") { dismiss() }
                                .foregroundColor(.appBlue)
                        }

                        Button {
                            // Pass email, password, AND address to the register function
                            viewModel.register(email: email, password: password, address: address)
                            // Consider dismissing only on successful registration,
                            // which might require a callback or publisher from AuthViewModel.
                            // For now, it dismisses immediately.
                            dismiss()
                        } label: {
                            Text("REGISTER")
                                .font(.custom("MarkerFelt-Wide", size: 48))
                                .shadow(color: .appBlack, radius: 1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 66)
                                .background(Color.appBlue)
                                .foregroundColor(.appWhite)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.appOrange)
                }
                .background(Color.appWhite)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appBlack, lineWidth: 4))
                .padding(24)
                Spacer()
            }
            .navigationTitle("Register") // Add a title to the sheet
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add a dismiss button to the toolbar for better UX
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
struct LoginRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterView(viewModel: AuthViewModel())
    }
}
