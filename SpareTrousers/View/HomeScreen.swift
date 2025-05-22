//
//  HomeScreen.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ───── Search bar under the nav bar ─────
                HStack(spacing: 8) {
                    TextField("Search", text: $searchText)
                        .padding(.leading, 12)
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )

                    Button {
                        // your search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.blue)

                // ───── Main content placeholder ─────
                ScrollView {
                    Color(.systemGray6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(edges: .bottom)

                // ───── Bottom orange bar ─────
                Button {
                    // your bottom-bar action
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .frame(height: 60)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            // Hide the default nav title—but style the nav bar to look like your header
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Center “Home” + pants icon
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Text("Home")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 2, y: 2)

                        // Replace "PantsIcon" with your actual asset name
                        Image("PantsIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }

                // Logout button on the right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// 📱 Xcode Canvas Preview
#Preview {
    HomeScreen(viewModel: AuthViewModel())
}
