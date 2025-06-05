//
//  WatchInboxView.swift
//  SpareTrousersWatch Watch App
//
//  Created by student on 05/06/25.
//


import SwiftUI

struct WatchInboxView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var inboxViewModel: InboxViewModel

    @State private var selectedMessage: InboxMessage?

    var body: some View {
        NavigationView {
            VStack {
                if inboxViewModel.isLoading && inboxViewModel.inboxMessages.isEmpty {
                    ProgressView("Loading...")
                } else if let errorMessage = inboxViewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if inboxViewModel.inboxMessages.isEmpty {
                    Text("Inbox is empty.")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(inboxViewModel.inboxMessages) { message in
                            NavigationLink(destination: WatchMessageDetailView(message: message)
                                            .environmentObject(inboxViewModel)
                                            .environmentObject(authViewModel)
                            ) {
                                WatchMessageRowView(message: message)
                            }
                            .onAppear {
                                // Optional: Mark as read on appear if desired, or on tap in detail
                                // For now, reading is handled by tapping in the iOS version.
                                // Let's keep it simple: tapping navigates. Read status handled in detail or by iOS app.
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inbox")
            .onAppear {
                if let userId = authViewModel.userSession?.uid {
                    inboxViewModel.setupListeners(
                        forUser: userId,
                        userDisplayName: authViewModel.userSession?.displayName,
                        userEmail: authViewModel.userSession?.email
                    )
                } else {
                    inboxViewModel.errorMessage = "User not logged in on watch."
                }
            }
            .onDisappear {
                // Optionally unsubscribe when the main inbox view disappears,
                // though for a single-page app, this might not be necessary until app termination.
                // inboxViewModel.unsubscribeAll()
            }
        }
    }
}
