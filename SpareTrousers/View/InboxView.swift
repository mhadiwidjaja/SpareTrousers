//
//  InboxView.swift
//  SpareTrousers
//
//  Created by student on 28/05/25.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    let topSectionCornerRadius: CGFloat = 18
    
    @State private var showingAddDummyMessageModal = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ───── BLUE HEADER ─────
                VStack(spacing: 10) {
                    Spacer().frame(height: 80)
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
                        
                        Image(
                            "SpareTrousers"
                        )
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
                        radius: 18,
                        corners: [.bottomLeft, .bottomRight]
                    )
                )
                .offset(y: -86)

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
                        ProgressView()
                            .padding(.top, 50)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    } else if viewModel.inboxMessages.isEmpty {
                        Text("Your inbox is empty.")
                            .foregroundColor(.appOffGray)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(
                                    viewModel.inboxMessages
                                ) { message in
                                    InboxRow(
                                        message: message,
                                        viewModel: viewModel
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(
                                .top,
                                topSectionCornerRadius + 10
                            )
                            .padding(.bottom, 80)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height + 86)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingAddDummyMessageModal) {
                AddDummyMessageView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - View for Adding Dummy Message (Modal Content)
struct AddDummyMessageView: View {
    @ObservedObject var viewModel: InboxViewModel
    @Environment(\.dismiss) var dismiss

    @State private var messageText: String = "Dummy request for 'Awesome Trousers'"
    @State private var dateLine: String = "\(Date().formatted(date: .numeric, time: .omitted)) - \(Calendar.current.date(byAdding: .day, value: 5, to: Date())!.formatted(date: .numeric, time: .omitted))"
    @State private var type: String = "rentalRequest"
    @State private var showsReject: Bool = true
    @State private var relatedItemName: String = "Awesome Trousers"

    let messageTypes = [
        "rentalRequest",
        "pickupReminder",
        "returnReminder",
        "info"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dummy Message Details")) {
                    TextField("Message Text", text: $messageText)
                    TextField("Date Line", text: $dateLine)
                    TextField("Related Item Name", text: $relatedItemName)
                    
                    Picker("Message Type", selection: $type) {
                        ForEach(messageTypes, id: \.self) { typeName in
                            Text(typeName.capitalized)
                        }
                    }
                    .onChange(of: type) { oldValue, newValue in
                        print("Type changed from \(oldValue) to \(newValue)")
                        showsReject = (newValue == "rentalRequest")
                        if newValue == "rentalRequest" {
                            messageText = "Dummy request for '\(relatedItemName)'"
                        } else if newValue == "pickupReminder" {
                            messageText = "Time to pick up '\(relatedItemName)'"
                        } else if newValue == "info" {
                            messageText = "Information regarding '\(relatedItemName)'"
                        } else {
                            messageText = "Reminder about '\(relatedItemName)'"
                        }
                    }
                    
                    Toggle("Shows Reject Button", isOn: $showsReject)
                }

                Button("Add Dummy Inbox Item") {
                    viewModel.createDummyInboxItem(
                        messageText: messageText,
                        dateLine: dateLine,
                        type: type,
                        showsReject: showsReject,
                        relatedItemName: relatedItemName
                    )
                    dismiss()
                }
            }
            .navigationTitle("Add Dummy Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if type == "rentalRequest" {
                    messageText = "Dummy request for '\(relatedItemName)'"
                } else if type == "pickupReminder" {
                    messageText = "Time to pick up '\(relatedItemName)'"
                } else if type == "info" {
                    messageText = "Information regarding '\(relatedItemName)'"
                } else {
                    messageText = "Reminder about '\(relatedItemName)'"
                }
                showsReject = (type == "rentalRequest")
            }
        }
    }
}

// MARK: - Model
struct InboxRequest: Identifiable {
    let id = UUID()
    let message: String
    let dateLine: String
    let showsReject: Bool
}

// MARK: - Row View
struct InboxRow: View {
    let message: InboxMessage
    @ObservedObject var viewModel: InboxViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {


                Text(message.dateLine)
                    .font(.caption)
                    .foregroundColor(.appOffGray)
            }

            Spacer()

            if message.type == "rentalRequest" {
                HStack(spacing: 12) {
                    Button {
                        viewModel.acceptRequest(message: message)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(
                                .system(size: 18, weight: .bold)
                            ) // Slightly smaller
                            .frame(width: 30, height: 30)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    if message.showsRejectButton {
                        Button {
                            viewModel.rejectRequest(message: message)
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
        .padding()
        .background(Color.appWhite)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    message.isRead ? Color.appOffWhite : Color.appBlack
                        .opacity(0.7),
                    lineWidth: message.isRead ? 1 : 2
                )
        )
        .opacity(message.isRead ? 0.8 : 1.0)
        .onTapGesture {
            if !message.isRead {
                viewModel.markMessageAsRead(messageId: message.id)
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
