//
//  WatchMessageDetailView.swift
//  SpareTrousers
//
//  Created by student on 05/06/25.
//


import SwiftUI

struct WatchMessageDetailView: View {
    @EnvironmentObject var inboxViewModel: InboxViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    let message: InboxMessage

    @State private var isLoadingAction = false
    @State private var showActionAlert = false
    @State private var actionAlertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(message.dateLine)
                    .font(.headline)
                    .padding(.bottom, 5)

                if let itemName = message.itemName {
                    InfoRow(label: "Item:", value: itemName)
                }
                if let otherPartyName = message.lenderName {
                    let fromOrTo = message.type.contains("request_received") ? "From:" : "Regarding:"
                    InfoRow(label: fromOrTo, value: otherPartyName)
                }
                InfoRow(label: "Received:", value: messageTimestamp(message.timestamp))
                
                Divider().padding(.vertical, 4)

                if message.type == inboxViewModel.MSG_TYPE_REQUEST_RECEIVED && message.showsRejectButton {
                    actionButtons(
                        acceptTitle: "Approve",
                        rejectTitle: "Decline",
                        acceptAction: { performAction { viewModel, currentMessage in viewModel.acceptRequest(message: currentMessage) } },
                                                rejectAction: { performAction { viewModel, currentMessage in viewModel.rejectRequest(message: currentMessage) } }
                    )
                } else if message.type == inboxViewModel.MSG_TYPE_LOCAL_BORROWER_RETURN_PROMPT {
                    actionButtons(
                        acceptTitle: "Returned It",
                        rejectTitle: "Not Yet",
                        acceptAction: { performAction { vm, msg in vm.handleBorrowerReturnedAction(message: msg, didReturn: true) } },
                        rejectAction: { performAction { vm, msg in vm.handleBorrowerReturnedAction(message: msg, didReturn: false) } }
                    )
                } else if message.type == inboxViewModel.MSG_TYPE_LENDER_CONFIRM_RECEIPT_PROMPT && message.showsRejectButton {
                    actionButtons(
                        acceptTitle: "Received",
                        rejectTitle: "Not Received",
                        acceptAction: { performAction { vm, msg in vm.handleLenderConfirmReceiptAction(message: msg, didReceive: true) } },
                        rejectAction: { performAction { vm, msg in vm.handleLenderConfirmReceiptAction(message: msg, didReceive: false) } }
                    )
                } else {
                    Text("No actions available for this message type on watch.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if isLoadingAction {
                    ProgressView()
                        .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Message Details")
        .onAppear {
            if !message.isRead {
                inboxViewModel.markMessageAsRead(messageId: message.id)
            }
        }
        .alert("Action Status", isPresented: $showActionAlert) {
            Button("OK") {
                if actionAlertMessage.lowercased().contains("success") || actionAlertMessage.lowercased().contains("approved") || actionAlertMessage.lowercased().contains("declined") {
                    dismiss()
                }
            }
        } message: {
            Text(actionAlertMessage)
        }
    }

    @ViewBuilder
    private func InfoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }

    @ViewBuilder
    private func actionButtons(acceptTitle: String, rejectTitle: String,
                               acceptAction: @escaping () -> Void,
                               rejectAction: @escaping () -> Void) -> some View {
        VStack(spacing: 10) {
            Button(action: acceptAction) {
                Text(acceptTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(isLoadingAction)

            if message.showsRejectButton {
                Button(action: rejectAction) {
                    Text(rejectTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isLoadingAction)
            }
        }
        .padding(.top)
    }

    private func performAction(_ action: @escaping (InboxViewModel, InboxMessage) -> Void) {
        guard !isLoadingAction else { return }
        isLoadingAction = true
        actionAlertMessage = ""

        action(inboxViewModel, message)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Simulated delay
            isLoadingAction = false
            if let vmError = inboxViewModel.errorMessage, !vmError.isEmpty {
                actionAlertMessage = vmError
                inboxViewModel.errorMessage = nil
            } else {
                actionAlertMessage = "Action processed."
            }
            showActionAlert = true
        }
    }
    
    private func messageTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
