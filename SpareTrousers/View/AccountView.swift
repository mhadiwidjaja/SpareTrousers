//
//  AccountView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

// MARK: - AccountView
struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    // State to control navigation to LoginRegisterView
    @State private var shouldNavigateToLoginRegister = false

    let topSectionCornerRadius: CGFloat = 18
    let email = "nahidgraduate.ai@gmail.com" // Placeholder
    let address = "Local Thunk, Balatro"     // Placeholder

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // NavigationLink that will be triggered by shouldNavigateToLoginRegister
                // It's "hidden" because its label is EmptyView and activation is programmatic.
                // This link must be within the NavigationView provided by HomeView.
                NavigationLink(
                    destination: LoginRegisterView(viewModel: authViewModel),
                    isActive: $shouldNavigateToLoginRegister
                ) {
                    EmptyView()
                }

                // ───── BLUE HEADER + PROFILE CARD ─────
                ZStack(alignment: .top) {
                    Color.appBlue
                        .edgesIgnoringSafeArea(.top)

                    VStack(spacing: 12) {
                        Spacer().frame(height: UIApplication.shared.connectedScenes
                            .filter { $0.activationState == .foregroundActive }
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .filter { $0.isKeyWindow }
                            .first?.safeAreaInsets.top ?? 0 + 20)

                        HStack {
                            Text("Account")
                                .font(.custom("MarkerFelt-Wide", size: 36))
                                .foregroundColor(.appWhite)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                            Spacer()
                            Image("SpareTrousers")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.appBlack)
                                Spacer()
                            }
                            Text(authViewModel.userSession?.email ?? email)
                                .font(.subheadline)
                                .foregroundColor(.appBlack)

                            HStack {
                                Text("Address")
                                    .font(.headline)
                                    .foregroundColor(.appBlack)
                                Spacer()
                            }
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.appBlack)
                        }
                        .padding()
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                }
                .frame(height: 306)
                .clipShape(
                    RoundedCorner(radius: topSectionCornerRadius,
                                  corners: [.bottomLeft, .bottomRight])
                )
                .offset(y: -86)

                // ───── WHITE SETTINGS AREA ─────
                ZStack(alignment: .top) {
                    Color.appWhite
                        .clipShape(
                            RoundedCorner(radius: topSectionCornerRadius,
                                          corners: [.topLeft, .topRight])
                        )
                    
                    VStack(spacing: 0) {
                        Button {
                            print("Account Settings tapped")
                        } label: {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.appBlack)
                                    .frame(width: 64, height: 64)
                                Text("Account Settings")
                                    .font(.title.bold())
                                    .foregroundColor(.appBlack)
                                Spacer()
                            }
                            .padding()
                        }

                        Divider()
                            .padding(.leading, 52)
                            .padding(.trailing, 52)

                        Button {
                            authViewModel.logout()
                            print("Logout button tapped, attempting to navigate.")
                            // Set the state to true to trigger navigation
                            shouldNavigateToLoginRegister = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                    .frame(width: 64, height: 64)
                                Text("Logout")
                                    .font(.title.bold())
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .background(Color.appWhite)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.appBlack, lineWidth: 2)
                    )
                    .padding(.horizontal)
                    .padding(.top, 24)
                }
                .frame(width: geo.size.width,
                       height: geo.size.height + 86 - 260 + 16)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            // The .navigationTitle for AccountView itself is usually set by the
            // TabView or whatever presents it, or can be set here if it's the top-level view in this tab.
            // .navigationTitle("Account") // Uncomment if needed
            // .navigationBarHidden(true) // Typically, if part of HomeView's tab structure, HomeView handles nav bar visibility
        }
    }
}

// MARK: - Preview
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrap in NavigationView for previewing navigation behavior
        NavigationView {
            AccountView()
                .environmentObject(AuthViewModel()) // Provide AuthViewModel for the preview
        }
    }
}
