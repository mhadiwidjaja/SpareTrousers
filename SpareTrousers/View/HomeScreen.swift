//
//  HomeScreen.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("Hello, world!")
                    .font(.title)

                // any other content…
            }
            .padding()
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}


//#Preview {
//    HomeScreen()
//}
