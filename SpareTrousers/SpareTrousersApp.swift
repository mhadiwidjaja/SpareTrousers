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

    // Initializes the application
    init() {
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font: \(name)")
            }
        }
        // Configures Firebase services when the app starts
        FirebaseApp.configure()
        print("Firebase configured!")

        let defaults = UserDefaults.standard
        // Checks if Firebase dummy items have been seeded before to prevent duplicate seeding.
        if !defaults
            .bool(forKey: "hasSeededFirebaseDummyItems_IntCategories_v1") {
            print(
                "--- Initiating Firebase dummy items seeding (Int Categories, one-time) ---"
            )
            let seedingService = SeedingService()
            seedingService.seedDummyItemsToFirebase()
            defaults
                .set(
                    true,
                    forKey: "hasSeededFirebaseDummyItems_IntCategories_v1"
                )
            print("--- Firebase dummy items seeding attempt completed ---")
        } else {
            print(
                "--- Firebase dummy items seeding already performed, skipping. ---"
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if viewModel.userSession != nil {
                HomeView()
                    .environmentObject(viewModel)
            } else {
                LoginRegisterView(viewModel: viewModel)
            }
        }
    }
}
