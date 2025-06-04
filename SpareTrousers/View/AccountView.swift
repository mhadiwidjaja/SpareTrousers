//
//  AccountView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingAccountSettingsModal = false
    let topSectionCornerRadius: CGFloat = 18
    
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

                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                            }
                            Divider().padding(.vertical, 2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayUsername)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                            }
                            Divider().padding(.vertical, 2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Address")
                                    .font(.headline)
                                    .foregroundColor(.appBlack.opacity(0.7))
                                Text(displayAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.appBlack)
                                    .lineLimit(2)
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
                .frame(height: 350)
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
                       height: geo.size.height + 86 - 260 + 16 + 20)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isShowingAccountSettingsModal) {
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
