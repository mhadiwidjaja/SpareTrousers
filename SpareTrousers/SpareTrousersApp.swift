//
//  SpareTrousersApp.swift
//  SpareTrousers
//
//  Created by student on 22/05/25.
//

import SwiftUI
import Firebase
@main
struct SpareTrousersApp: App {
    @StateObject var viewModel = AuthViewModel()
    init() {
            FirebaseApp.configure() // Initialize Firebase when the app starts
        }
    var body: some Scene {
        WindowGroup {
            if viewModel.userSession != nil {
                            HomeScreen(viewModel: viewModel)
                        } else {
                            LoginRegisterView(viewModel: viewModel)
                        }
        }
    }
}
