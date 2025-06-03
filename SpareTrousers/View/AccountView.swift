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
    @State private var isShowingAccountSettingsModal = false
    // Navigation state for logout, if AccountView handles it directly.
    // If root view handles logout navigation, this might not be needed here.
    @State private var shouldNavigateToLoginAfterLogout = false


    let topSectionCornerRadius: CGFloat = 18
    
    // Computed properties for display, using placeholders if data is nil
    private var displayEmail: String {
        authViewModel.userSession?.email ?? "Email not available"
    }
    
    private var displayUsername: String {
        authViewModel.userSession?.displayName ?? "Username not set"
    }

    private var displayAddress: String {
        authViewModel.userAddress ?? "Address not set"
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Hidden NavigationLink for logout, if AccountView triggers it
                // This assumes AccountView is within a NavigationView.
                NavigationLink(
                    destination: LoginRegisterView(viewModel: authViewModel), // Ensure LoginRegisterView can take AuthViewModel
                    isActive: $shouldNavigateToLoginAfterLogout
                ) { EmptyView() }


                // ───── BLUE HEADER + PROFILE CARD ─────
                ZStack(alignment: .top) {
                    Color.appBlue
                        .edgesIgnoringSafeArea(.top)

                    VStack(spacing: 12) {
                        Spacer()
                            .frame(
                                height: UIApplication.shared.connectedScenes
                                    .filter { $0.activationState == .foregroundActive }
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows
                                    .filter { $0.isKeyWindow }
                                    .first?.safeAreaInsets.top ?? 0 + 30)

                        HStack {
                            Text("Account")
                                .font(.custom("MarkerFelt-Wide", size: 36))
                                .foregroundColor(.appWhite)
                                .shadow(color: .appBlack, radius: 1) // Repeated shadows for emphasis
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                                .shadow(color: .appBlack, radius: 1)
                            Spacer()
                            Image("SpareTrousers") // Ensure this image is in your assets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        .padding(.horizontal)

                        // Profile Information Card
                        VStack(alignment: .leading, spacing: 10) { // Increased spacing a bit
                            // Email
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                            }
                            Divider().padding(.vertical, 2)

                            // Username (Display Name)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayUsername)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                            }
                            Divider().padding(.vertical, 2)
                            
                            // Address
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Address")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                                    .lineLimit(2) // Allow address to wrap if long
                            }
                        }
                        .padding()
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .shadow(
                            color: .black.opacity(0.1),
                            radius: 1,
                            x: 0,
                            y: 1
                        )
                        .padding(.horizontal)
                    }
                }
                .frame(height: 350) // Adjusted height to accommodate username
                .clipShape(
                    RoundedCorner(radius: topSectionCornerRadius,
                                  corners: [.bottomLeft, .bottomRight])
                )
                .offset(y: -86) // Keep your original offset

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
                            isShowingAccountSettingsModal = true
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
                            print("Logout button tapped.")
                            // If your app's root view handles navigation based on userSession,
                            // this should be enough. The NavigationLink above is an alternative
                            // if AccountView itself needs to trigger a push to LoginRegisterView.
                            // For root view switching, `shouldNavigateToLoginAfterLogout = true` might not be needed.
                            // If it IS needed for your setup:
                            // self.shouldNavigateToLoginAfterLogout = true
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
                       height: geo.size.height + 86 - 260 + 16 + 20) // Adjusted height slightly for username
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68) // Keep your original offset
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isShowingAccountSettingsModal) {
                // Ensure AccountSettingsModalView also gets AuthViewModel if needed
                AccountSettingsModalView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Preview
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountView()
                .environmentObject(AuthViewModel())
        }
    }
}
