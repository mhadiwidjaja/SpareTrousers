//
//  SpareTrousersWatchApp.swift
//  SpareTrousersWatch Watch App
//
//  Created by student on 05/06/25.
//

import SwiftUI
import FirebaseCore

@main
struct SpareTrousersWatchApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var inboxViewModel = InboxViewModel()
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured for SpareTrousersWatch!")
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.userSession != nil {
                WatchInboxView()
                    .environmentObject(authViewModel)
                    .environmentObject(inboxViewModel)
            } else {
                NavigationView {
                    WatchLoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
