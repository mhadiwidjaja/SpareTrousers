//
//  LoginView.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//


import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Login")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                viewModel.login(email: email, password: password)
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Don't have an account? Register") {
                showingRegister = true
            }
            .font(.footnote)
            .sheet(isPresented: $showingRegister) {
                RegisterView(viewModel: viewModel)
            }

            Spacer()
        }
        .padding()
    }
}
