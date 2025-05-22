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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

//#Preview {
//    HomeScreen()
//}
