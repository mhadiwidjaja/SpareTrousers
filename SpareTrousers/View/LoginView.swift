//
//  LoginView.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import SwiftUI




import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email      = ""
    @State private var password   = ""
    @State private var showingRegister = false

    var body: some View {
        ZStack {
            // 1) Rounded card with black stroke
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )

            VStack(spacing: 0) {
                // 2) Top: blue area
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

                    // “Welcome to” + “Spare Trousers” with bubble/shadow
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
                    // 3) Bottom: orange area
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

                        // Register link
                        HStack(spacing: 4) {
                            Text("New User?")
                                .foregroundColor(.black)
                            Button("Register") {
                                showingRegister = true
                            }
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        // Login button
                        Button(action: {
                            viewModel.login(email: email, password: password)
                        }) {
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
        .sheet(isPresented: $showingRegister) {
            RegisterView(viewModel: viewModel)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
//        .previewLayout(.sizeThatFits)
//        .padding()
}
