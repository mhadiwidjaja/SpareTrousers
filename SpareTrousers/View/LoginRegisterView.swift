//
//  LoginRegisterView.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import SwiftUI

struct LoginRegisterView: View {
  
    @ObservedObject var viewModel: AuthViewModel
    
    // Login form state
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    
    // Sheet toggle
    @State private var showingRegister = false

    var body: some View {
        ZStack {
            // Card outline
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )

            VStack(spacing: 0) {
                // MARK: — LOGIN TOP (Blue)
                VStack(spacing: 16) {
                    Spacer().frame(height: 24)

                    // Logo placeholder
                    ZStack {
                        Color.blue
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        Text("Logo")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    // Bubble-style title
                    VStack(spacing: 4) {
                        Text("Welcome to")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                        Text("Spare Trousers")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 2, y: 2)
                    }
                    // MARK: — LOGIN BOTTOM (Orange)
                    VStack(spacing: 16) {
                        // Email
                        TextField("Enter email", text: $loginEmail)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )

                        // Password
                        SecureField("Enter password", text: $loginPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )

                        // “New User? Register” on the right
                        HStack(spacing: 4) {
                            Text("New User?")
                                .foregroundColor(.black)
                            Button("Register") {
                                showingRegister = true
                            }
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        // LOGIN button
                        Button {
                            viewModel.login(email: loginEmail, password: loginPassword)
                        } label: {
                            Text("LOGIN")
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.3),
                                        radius: 2, x: 1, y: 1)
                        }
                    }
                    .padding(20)
                    .background(Color.orange)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.blue)

                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(24)
        // Present the matching Register card
        .sheet(isPresented: $showingRegister) {
            RegisterCard(viewModel: viewModel)
        }
    }
}

//struct RegisterCard: View {
//    @ObservedObject var viewModel: AuthViewModel
//    @Environment(\.dismiss) private var dismiss
//
//    // Register form state
//    @State private var email = ""
//    @State private var password = ""
//
//    var body: some View {
//        ZStack {
//            // Same card outline
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.black, lineWidth: 4)
//                )
//
//            VStack(spacing: 0) {
//                // TOP: Blue header with “Register”
//                VStack(spacing: 16) {
//                    Spacer().frame(height: 24)
//
//                    Text("Register")
//                        .font(.largeTitle).bold()
//                        .foregroundColor(.white)
//                        .shadow(color: .black, radius: 2, x: 2, y: 2)
//
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity)
//                .background(Color.blue)
//
//                // BOTTOM: Orange form area
//                VStack(spacing: 16) {
//                    TextField("Enter email", text: $email)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 2)
//                        )
//
//                    SecureField("Enter password", text: $password)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 2)
//                        )
//
//                    // REGISTER button
//                    Button {
//                        viewModel.register(email: email, password: password)
//                        dismiss()
//                    } label: {
//                        Text("REGISTER")
//                            .font(.title2).bold()
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 12)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .shadow(color: .black.opacity(0.3),
//                                    radius: 2, x: 1, y: 1)
//                    }
//                }
//                .padding(20)
//                .background(Color.orange)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//        }
//        .padding(24)
//    }
//}
struct RegisterCard: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Card background + border
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )

            VStack(spacing: 0) {
                // ───── TOP (Blue) ─────
                VStack(spacing: 16) {
                    Spacer().frame(height: 24)

                    // Pants icon (replace "PantsIcon" with your asset name)
                    Image("PantsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)

                    // Bubble-style header
                    VStack(spacing: 4) {
                        Text("Welcome to")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)

                        Text("Spare Trousers")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 2, y: 2)
                    }
                    // ───── BOTTOM (Orange) ─────
                    VStack(spacing: 16) {
                        // Email field
                        TextField("Enter email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )

                        // Password field
                        SecureField("Enter password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )

                        // “Have an account? Login” link on the right
                        HStack(spacing: 4) {
                            Text("Have an account?")
                                .foregroundColor(.black)
                            Button("Login") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        // REGISTER button
                        Button {
                            viewModel.register(email: email, password: password)
                            dismiss()
                        } label: {
                            Text("REGISTER")
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.3),
                                        radius: 2, x: 1, y: 1)
                        }
                    }
                    .padding(20)
                    .background(Color.orange)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.blue)


            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(24)
    }
}



/// 📱 Xcode Canvas Preview
#Preview {
    LoginRegisterView(viewModel: AuthViewModel())
}
