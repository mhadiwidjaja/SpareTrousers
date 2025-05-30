//
//  AccountView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct AccountView: View {
    let topSectionCornerRadius: CGFloat = 18

    // placeholder user info
    let email = "nahidgraduate.ai@gmail.com"
    let address = "Local Thunk, Balatro"

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ───── BLUE HEADER + PROFILE CARD ─────
                ZStack(alignment: .top) {
                    // Blue background
                    Color.appBlue
                        .edgesIgnoringSafeArea(.top)

                    VStack(spacing: 12) {
                        Spacer().frame(height: 80)

                        // Title + logo
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

                        // Email/Address card inside header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.appBlack)
                                Spacer()
                            }
                            Text(email)
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
                        // Account Settings row
                        
                        Button {
                            // navigate to settings
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

                        // Logout row
                        Button {
                            // perform logout
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
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
