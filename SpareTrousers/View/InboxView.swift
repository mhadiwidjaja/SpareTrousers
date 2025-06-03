//
//  InboxView.swift
//  SpareTrousers
//
//  Created by student on 28/05/25.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // To get current user's UID
    @StateObject private var viewModel = InboxViewModel() // Use the one from swiftui_inbox_view_model
    
    let topSectionCornerRadius: CGFloat = 18
    @State private var showingAddDummyMessageModal = false // For the plus button

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ───── BLUE HEADER ─────
                VStack(spacing: 10) {
                    // Dynamic spacer for status bar height
                    Spacer().frame(height: UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows
                        .filter { $0.isKeyWindow }
                        .first?.safeAreaInsets.top ?? 0 + 30) // Adjusted padding

                    HStack {
                        Text("Inbox")
                            .font(.custom("MarkerFelt-Wide", size: 36))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                        Spacer()
                        Button {
                            showingAddDummyMessageModal = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.appWhite)
                        }
                        .padding(.trailing, 5)
                        
                        Image("SpareTrousers") // Ensure this image is in your assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .background(Color.appBlue.edgesIgnoringSafeArea(.top))
                .clipShape(
                    RoundedCorner(
                        radius: topSectionCornerRadius, // Use the defined corner radius
                        corners: [.bottomLeft, .bottomRight]
                    )
                )
                .offset(y: -86) // Offset to pull header down
                .zIndex(1) // Ensure header is above the content area initially

                // ───── WHITE CONTENT AREA ─────
                ZStack(alignment: .top) {
                    Color.appWhite
                        .clipShape(
                            RoundedCorner(
                                radius: topSectionCornerRadius,
                                corners: [.topLeft, .topRight]
                            )
                        )

                    if viewModel.isLoading {
                        ProgressView("Loading messages...")
                            .padding(.top, topSectionCornerRadius + 20) // Adjust top padding
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                            .padding(.top, topSectionCornerRadius)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    } else if viewModel.inboxMessages.isEmpty {
                        Text("Your inbox is empty.")
                            .foregroundColor(.appOffGray) // Use defined color
                            .padding()
                            .padding(.top, topSectionCornerRadius + 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) { // Spacing between rows
                                ForEach(viewModel.inboxMessages) { message in
                                    InboxMessageRow(message: message, viewModel: viewModel) // Pass viewModel
                                        .padding(.horizontal) // Padding for each row within the scroll content
                                }
                            }
                            .padding(.top, topSectionCornerRadius + 10) // Padding for the start of the list content
                            .padding(.bottom, 80) // Padding at the end of the list for BottomNavBar clearance
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height + 86) // Adjust height calculation
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68) // Offset to pull content area up
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingAddDummyMessageModal) {
                AddDummyMessageModalView(inboxViewModel: viewModel, authViewModel: authViewModel)
            }
            .onAppear {
                if let userId = authViewModel.userSession?.uid {
                    viewModel.subscribeToInboxMessages(forUser: userId)
                } else {
                    viewModel.errorMessage = "User not logged in."
                    print("InboxView: No user logged in to fetch messages for.")
                }
            }
            // .onDisappear { // Handled in ViewModel's deinit
            //     viewModel.unsubscribeFromInboxMessages()
            // }
        }
        // This NavigationView might be redundant if HomeView provides one.
        // If InboxView is a tab within HomeView's NavigationView, remove this.
        // For standalone preview or if it's a root of a tab, keep it.
        // .navigationViewStyle(StackNavigationViewStyle()) // Only if it has its own NavigationView
    }
}

// Updated InboxMessageRow to match user's uploaded file's styling and functionality
struct InboxMessageRow: View {
    let message: InboxMessage
    @ObservedObject var viewModel: InboxViewModel // To call accept/reject

    // Date formatter for display (can be made static or passed if performance is a concern)
    private var displayTimestamp: String {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 12) { // Added spacing
            // Unread indicator logic from the Canvas version
            if !message.isRead {
                Circle().fill(Color.appBlue).frame(width: 10, height: 10).padding(.top, 4)
            } else {
                Circle().fill(Color.clear).frame(width: 10, height: 10).padding(.top, 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.dateLine) // Using dateLine as the main message text as per user's InboxRow
                    .font(.headline) // Adjusted font
                    .fontWeight(message.isRead ? .regular : .bold) // Bold if unread
                    .lineLimit(2) // Allow two lines for the main message

                // Display item name if available
                if let itemName = message.itemName {
                    Text("Item: \(itemName)")
                        .font(.subheadline)
                        .foregroundColor(.appOffGray) // Use defined color
                        .lineLimit(1)
                }

                // Display "From" or "To" based on context (lenderName stores the other party)
                if let otherParty = message.lenderName {
                     Text("User: \(otherParty)") // Simplified for now
                        .font(.caption)
                        .foregroundColor(.appOffGray)
                }
                
                Text(displayTimestamp) // Timestamp from Canvas version
                    .font(.caption2)
                    .foregroundColor(.appOffGray)
            }

            Spacer() // Pushes content to the left

            // Accept/Reject buttons based on message type and showsRejectButton flag
            if message.type == "request_received" { // Assuming "request_received" is the type for rental requests
                HStack(spacing: 12) {
                    Button {
                        // viewModel.acceptRequest(message: message) // TODO: Implement in InboxViewModel
                        print("Accept tapped for message: \(message.id)")
                        viewModel.markMessageAsRead(messageId: message.id) // Example action
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 30, height: 30)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    if message.showsRejectButton {
                        Button {
                            // viewModel.rejectRequest(message: message) // TODO: Implement in InboxViewModel
                            print("Reject tapped for message: \(message.id)")
                            viewModel.markMessageAsRead(messageId: message.id) // Example action
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 30, height: 30)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding() // Padding around the HStack
        .background(Color.appWhite) // White background for the row
        .cornerRadius(10)
        .overlay( // Border based on read status
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    message.isRead ? Color.appOffWhite : Color.appBlack.opacity(0.7), // Lighter border if read
                    lineWidth: message.isRead ? 1 : 2 // Thicker border if unread
                )
        )
        .opacity(message.isRead ? 0.8 : 1.0) // Slightly faded if read
        .contentShape(Rectangle()) // Ensure entire row is tappable
        .onTapGesture {
            if !message.isRead {
                viewModel.markMessageAsRead(messageId: message.id)
            }
            // TODO: Implement navigation to message detail or transaction detail
            print("Row tapped for message: \(message.id), related transaction: \(message.relatedTransactionId ?? "None")")
        }
    }
}

// Placeholder for AddDummyMessageModalView
struct AddDummyMessageModalView: View {
    @ObservedObject var inboxViewModel: InboxViewModel
    @Environment(\.dismiss) var dismiss
    // Add @State vars for dummy message fields if needed

    var body: some View {
        NavigationView {
            VStack {
                Text("Add Dummy Message (Placeholder)")
                Button("Add Example Message") {
                    // Example: inboxViewModel.createDummyInboxItem(...)
                    // This function would need to be added to InboxViewModel
                    print("Attempting to add dummy message.")
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}


// MARK: - Preview
struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthViewModel = AuthViewModel()
        mockAuthViewModel.userSession = UserSession(uid: "previewUserID", email: "preview@example.com", displayName: "Preview User")

        // To see messages in preview, you'd populate mockInboxViewModel.inboxMessages
        // as done in the previous Canvas version's preview.
        // For this preview, InboxView will create its own InboxViewModel and attempt to fetch.

        return InboxView()
            .environmentObject(mockAuthViewModel)
    }
}
