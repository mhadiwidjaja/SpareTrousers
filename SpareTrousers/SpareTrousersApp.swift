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
        FirebaseApp.configure()
        print("Firebase configured!")

        let defaults = UserDefaults.standard
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
            } else {
                LoginRegisterView(viewModel: viewModel)
            }
        }
    }
}
