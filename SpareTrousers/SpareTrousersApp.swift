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
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font: \(name)")
            }
        }
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
