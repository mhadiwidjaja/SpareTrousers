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

    var body: some View {
        VStack {
            Spacer()

            // ───── Card VStack ─────
            VStack(spacing: 0) {
                // Blue Header
                VStack(spacing: 16) {
                    Spacer().frame(height: 24)

                    ZStack {
                        Color.blue
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
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                        Text("Spare Trousers")
                            .font(.custom("MarkerFelt-Wide", size: 40))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                    }
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(Color.blue)

                // Orange Form
                VStack(spacing: 16) {
                    TextField("Enter email", text: $loginEmail)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )

                    SecureField("Enter password", text: $loginPassword)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )

                    HStack {
                        Spacer()
                        Text("New User?")
                        Button("Register") { showingRegister = true }
                            .foregroundColor(.blue)
                    }

                    Button {
                        viewModel
                            .login(email: loginEmail, password: loginPassword)
                    } label: {
                        Text("LOGIN")
                            .font(.custom("MarkerFelt-Wide", size: 48))
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)       // ensure full‐width orange
                .padding(20)
                .background(Color.orange)
            }
            .background(Color.white)                               // white fill
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )         // clip all children
            .overlay(                                              // black border on top
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 4)
            )
            .padding(
                24
            )                                           // outer padding

            Spacer()
        }
        .sheet(isPresented: $showingRegister) {
            RegisterCard(viewModel: viewModel)
        }
    }
}

struct RegisterCard: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Spacer()

            // ───── Card VStack ─────
            VStack(spacing: 0) {
                // Blue Header
                VStack(spacing: 16) {
                    Spacer().frame(height: 24)

                    Image("SpareTrousers")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    VStack(spacing: -8) {
                        Text("Welcome to")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                        Text("Spare Trousers")
                            .font(.custom("MarkerFelt-Wide", size: 40))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                    }
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(Color.blue)

                // Orange Form
                VStack(spacing: 16) {
                    TextField("Enter email", text: $email)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )

                    SecureField("Enter password", text: $password)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )

                    HStack {
                        Spacer()
                        Text("Have an account?")
                        Button("Login") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }

                    Button {
                        viewModel.register(email: email, password: password)
                        dismiss()
                    } label: {
                        Text("REGISTER")
                            .font(.custom("MarkerFelt-Wide", size: 48))
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 66)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)    // ensures full‐width orange
                .padding(20)
                .background(Color.orange)
            }
            .background(Color.white)                     // white fill
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            ) // clip to rounded card
            .overlay(                                      // black border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 4)
            )
            .padding(24)

            Spacer()
        }
    }
}



/// 📱 Xcode Canvas Preview
#Preview {
    LoginRegisterView(viewModel: AuthViewModel())
}
