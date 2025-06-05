//
//  InboxView.swift
//  SpareTrousers
//
//  Created by student on 28/05/25.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = InboxViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let topSectionCornerRadius: CGFloat = 18
    @State private var showingAddDummyMessageModal = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                InboxHeaderView(
                    topSectionCornerRadius: topSectionCornerRadius,
                    showingAddDummyMessageModal: $showingAddDummyMessageModal,
                    horizontalSizeClass: horizontalSizeClass
                )
                .offset(y: horizontalSizeClass == .compact ? -86 : 0)
                .zIndex(1)

                InboxContentView(
                    viewModel: viewModel,
                    topSectionCornerRadius: topSectionCornerRadius,
                    geo: geo,
                    horizontalSizeClass: horizontalSizeClass
                )
                .offset(y: horizontalSizeClass == .compact ? -68 : 0)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingAddDummyMessageModal) {
                AddDummyMessageModalView(inboxViewModel: viewModel, authViewModel: authViewModel)
            }
            .onAppear {
                if let userId = authViewModel.userSession?.uid {
                    viewModel.setupListeners(
                        forUser: userId,
                        userDisplayName: authViewModel.userSession?.displayName,
                        userEmail: authViewModel.userSession?.email
                    )
                } else {
                    viewModel.errorMessage = "User not logged in."
                }
            }
            .navigationTitle(horizontalSizeClass == .regular ? "Inbox" : "")
            .navigationBarHidden(horizontalSizeClass == .compact)
        }
    }
}

struct InboxHeaderView: View {
    let topSectionCornerRadius: CGFloat
    @Binding var showingAddDummyMessageModal: Bool
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first?.safeAreaInsets.top ?? 0 + 30)
            

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
                Button { showingAddDummyMessageModal = true } label: {
                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.appWhite)
                }
                .padding(.trailing, 5)
                Image("SpareTrousers").resizable().scaledToFit().frame(width: 50, height: 50)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10).background(Color.appBlue.edgesIgnoringSafeArea(.top))
        .background(Color.appBlue.edgesIgnoringSafeArea(horizontalSizeClass == .compact ? .top : []))
        .clipShape(RoundedCorner(radius: topSectionCornerRadius, corners: [.bottomLeft, .bottomRight]))
    }
}

struct InboxContentView: View {
    @ObservedObject var viewModel: InboxViewModel
    let topSectionCornerRadius: CGFloat
    let geo: GeometryProxy
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        ZStack(alignment: .top) {
            Color.appWhite.clipShape(RoundedCorner(radius: topSectionCornerRadius, corners: [.topLeft, .topRight]))
            if viewModel.isLoading && viewModel.inboxMessages.isEmpty {
                ProgressView("Loading messages...").padding(.top, topSectionCornerRadius + 20)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red).padding().padding(.top, topSectionCornerRadius)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center).multilineTextAlignment(.center)
            } else if viewModel.inboxMessages.isEmpty {
                Text("Your inbox is empty.").foregroundColor(.appOffGray).padding().padding(.top, topSectionCornerRadius + 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.inboxMessages) { message in
                            InboxMessageRow(message: message, viewModel: viewModel, authViewModel: _authViewModel)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, topSectionCornerRadius + 10).padding(.bottom, 80)
                }
            }
        }
        .frame(width: geo.size.width, height: geo.size.height + 86).ignoresSafeArea(edges: .bottom)
    }
    @EnvironmentObject var _authViewModel: AuthViewModel
}

struct InboxMessageRow: View {
    let message: InboxMessage
    @ObservedObject var viewModel: InboxViewModel
    @ObservedObject var authViewModel: AuthViewModel

    private var displayTimestamp: String {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter(); formatter.dateStyle = .short; formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 12) {
            if !message.isRead {
                Circle().fill(Color.appBlue).frame(width: 10, height: 10).padding(.top, 4)
            } else {
                Circle().fill(Color.clear).frame(width: 10, height: 10).padding(.top, 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.dateLine)
                    .font(.headline).fontWeight(message.isRead ? .regular : .bold).lineLimit(3)
                if let itemName = message.itemName {
                    Text("Item: \(itemName)")
                        .font(.subheadline).foregroundColor(.appOffGray).lineLimit(1)
                }
                if let otherPartyName = message.lenderName {
                    Text(message.type.contains("borrower") ? "To: \(otherPartyName)" : "From: \(otherPartyName)")
                        .font(.caption).foregroundColor(.appOffGray)
                }
                Text(displayTimestamp).font(.caption2).foregroundColor(.appOffGray)
            }
            Spacer()

            // Action buttons based on message type
            if message.type == viewModel.MSG_TYPE_REQUEST_RECEIVED && message.showsRejectButton {
                actionButtons(acceptAction: { viewModel.acceptRequest(message: message) },
                              rejectAction: { viewModel.rejectRequest(message: message) })
            } else if message.type == viewModel.MSG_TYPE_LOCAL_BORROWER_RETURN_PROMPT {
                actionButtons(acceptAction: { viewModel.handleBorrowerReturnedAction(message: message, didReturn: true) },
                              rejectAction: { viewModel.handleBorrowerReturnedAction(message: message, didReturn: false) })
            } else if message.type == viewModel.MSG_TYPE_LENDER_CONFIRM_RECEIPT_PROMPT && message.showsRejectButton {
                actionButtons(acceptAction: { viewModel.handleLenderConfirmReceiptAction(message: message, didReceive: true) },
                              rejectAction: { viewModel.handleLenderConfirmReceiptAction(message: message, didReceive: false) })
            }
        }
        .padding()
        .background(Color.appWhite)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(message.isRead ? Color.appOffWhite : Color.appBlack.opacity(0.7), lineWidth: message.isRead ? 1 : 2))
        .opacity(message.isRead ? 0.8 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            if !message.isRead { viewModel.markMessageAsRead(messageId: message.id) }
        }
    }

    @ViewBuilder
    private func actionButtons(acceptAction: @escaping () -> Void, rejectAction: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Button(action: acceptAction) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .buttonStyle(BorderlessButtonStyle())

            if message.showsRejectButton {
                Button(action: rejectAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 30, height: 30)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct AddDummyMessageModalView: View {
    @ObservedObject var inboxViewModel: InboxViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var dateLine: String = "New item request!"
    @State private var messageType: String = "request_received"
    @State private var showsRejectButton: Bool = true
    @State private var relatedTransactionId: String = ""
    @State private var lenderName: String = ""
    @State private var itemName: String = "Sample Item"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var submissionSuccessful = false
    let availableMessageTypes = ["request_received", "request_approved", "request_declined", "reminder", "general_info"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Message Details")) {
                    TextField("Message Line", text: $dateLine)
                    Picker("Message Type", selection: $messageType) {
                        ForEach(availableMessageTypes, id: \.self) { type in Text(type.replacingOccurrences(of: "_", with: " ").capitalized) }
                    }
                    .onChange(of: messageType) { newValue in showsRejectButton = (newValue == "request_received") }
                    Toggle("Shows Reject Button", isOn: $showsRejectButton).disabled(messageType != "request_received")
                    TextField("Related Item Name (Optional)", text: $itemName)
                    TextField("Other User's Name (Optional)", text: $lenderName)
                    TextField("Related Transaction ID (Optional)", text: $relatedTransactionId)
                }
                Section { Button("Add Dummy Message to My Inbox") { addDummyMessage() }.frame(maxWidth: .infinity, alignment: .center) }
            }
            .navigationTitle("New Dummy Message").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Add") { addDummyMessage() } }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(submissionSuccessful ? "Success" : "Error"), message: Text(alertMessage),
                      dismissButton: .default(Text("OK")) { if submissionSuccessful { dismiss() } })
            }
            .onAppear {
                if let name = authViewModel.userSession?.displayName { self.lenderName = name }
                else if let email = authViewModel.userSession?.email { self.lenderName = email }
            }
        }
    }

        func addDummyMessage() {
            guard let currentUid = authViewModel.userSession?.uid else {
                alertMessage = "You need to be logged in to add a message."
                submissionSuccessful = false; showAlert = true; return
            }
            if dateLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                alertMessage = "Message line cannot be empty."
                submissionSuccessful = false; showAlert = true; return
            }
            inboxViewModel.createAndSaveDummyMessage(
                forUserUid: currentUid,
                dateLine: dateLine, type: messageType, showsRejectButton: showsRejectButton,
                relatedTransactionId: relatedTransactionId.isEmpty ? nil : relatedTransactionId,
                lenderName: lenderName.isEmpty ? nil : lenderName,
                itemName: itemName.isEmpty ? nil : itemName
            ) { success, errorString in
                if success {
                    alertMessage = "Dummy message added successfully!"; submissionSuccessful = true
                } else {
                    alertMessage = errorString ?? "Failed to add dummy message."; submissionSuccessful = false
                }
                showAlert = true
            }
        }
}


// MARK: - Preview
struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthViewModel = AuthViewModel()
        mockAuthViewModel.userSession = UserSession(uid: "previewUserID", email: "preview@example.com", displayName: "Preview User")
        return InboxView().environmentObject(mockAuthViewModel)
    }
}
