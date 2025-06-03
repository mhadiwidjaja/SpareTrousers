//
//  RequestView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth





//struct RequestView: View {
//    let item: DisplayItem
//    @State private var startDate = Date()
//    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
//    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    private var dbRef: DatabaseReference = Database.database().reference()
//
//    private var dateFormatterISO: ISO8601DateFormatter {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter
//    }
//    private var monthYearFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy" // Corrected and completed date format
//        return formatter
//    }
//
//    var dateRange: ClosedRange<Date> {
//        let today = Calendar.current.startOfDay(for: Date())
//        let distantFuture = Calendar.current.date(byAdding: .year, value: 5, to: today)!
//        return today...distantFuture
//    }
//    
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @State private var requestSuccessful = false
//
//    // Explicit initializer to ensure it's accessible
//    // This is often needed if the struct is in one file and used in another,
//    // or if default memberwise initializer's access level is too restrictive.
//    init(item: DisplayItem) {
//        self.item = item
//        // Initialize @State properties if they depend on `item` or need specific setup
//        // For startDate and endDate, their default initialization above is fine.
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .center, spacing: 20) {
//                Text("Borrow Details")
//                    .font(.largeTitle).fontWeight(.bold).padding(.top, 20)
//
//                HStack(spacing: 15) {
//                    if UIImage(named: item.imageName) != nil {
//                        Image(item.imageName).resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(10).clipped()
//                    } else {
//                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 80, height: 80).cornerRadius(10).overlay(Text("No\nImage").font(.caption).multilineTextAlignment(.center))
//                    }
//                    VStack(alignment: .leading) {
//                        Text(item.name).font(.title2).fontWeight(.semibold).lineLimit(2)
//                        Text(item.rentalPrice).font(.headline).foregroundColor(.gray)
//                    }
//                    Spacer()
//                }.padding(.horizontal)
//                Divider()
//
//                // Start Date Picker
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Select Start Date").font(.headline)
//                    HStack {
//                        Text(monthYearFormatter.string(from: startDate)).font(.title3).bold()
//                        Spacer()
//                        Button(action: {
//                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate), newDate >= dateRange.lowerBound { startDate = newDate }
//                        }) { Image(systemName: "chevron.left") }
//                        Button(action: {
//                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate), newDate <= dateRange.upperBound { startDate = newDate }
//                        }) { Image(systemName: "chevron.right") }
//                    }.padding(.horizontal, 5)
//                    DatePicker("Start Date", selection: $startDate, in: dateRange, displayedComponents: .date)
//                        .datePickerStyle(GraphicalDatePickerStyle()).labelsHidden()
//                        .onChange(of: startDate) { newStartDate in if newStartDate > endDate { endDate = newStartDate } }
//                }.padding(.horizontal)
//                Divider()
//
//                // End Date Picker
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Select End Date").font(.headline)
//                    HStack {
//                        Text(monthYearFormatter.string(from: endDate)).font(.title3).bold()
//                        Spacer()
//                        Button(action: {
//                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate), newDate >= max(startDate, dateRange.lowerBound) { endDate = newDate }
//                        }) { Image(systemName: "chevron.left") }
//                        Button(action: {
//                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: endDate), newDate <= dateRange.upperBound { endDate = newDate }
//                        }) { Image(systemName: "chevron.right") }
//                    }.padding(.horizontal, 5)
//                    DatePicker("End Date", selection: $endDate, in: max(startDate, dateRange.lowerBound)...dateRange.upperBound, displayedComponents: .date)
//                        .datePickerStyle(GraphicalDatePickerStyle()).labelsHidden()
//                }.padding(.horizontal)
//                Spacer(minLength: 30)
//
//                Button(action: submitTransaction) {
//                    Text("Send Request")
//                        .font(.title2).fontWeight(.bold).foregroundColor(.white).padding()
//                        .frame(maxWidth: .infinity).background(Color.orange).cornerRadius(12)
//                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
//                }
//                .padding(.horizontal).padding(.bottom, 20)
//            }
//        }
//        .navigationTitle("Borrow Details").navigationBarTitleDisplayMode(.inline)
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text(requestSuccessful ? "Success" : "Error"),
//                message: Text(alertMessage),
//                dismissButton: .default(Text("OK")) {
//                    if requestSuccessful {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//            )
//        }
//    }
//
//    func submitTransaction() {
//        guard let borrowerUid = authViewModel.userSession?.uid else {
//            alertMessage = "Error: You must be logged in to make a request."
//            requestSuccessful = false; showAlert = true; print(alertMessage); return
//        }
//        guard let ownerUid = item.ownerUid, !ownerUid.isEmpty else {
//            alertMessage = "Error: Item owner information is missing."
//            requestSuccessful = false; showAlert = true; print(alertMessage); return
//        }
//        if endDate < startDate {
//            alertMessage = "Error: End date cannot be before start date."
//            requestSuccessful = false; showAlert = true; return
//        }
//
//        let transactionId = UUID().uuidString
//        let newTransaction = Transaction(
//            id: transactionId,
//            transactionDate: dateFormatterISO.string(from: Date()),
//            startTime: dateFormatterISO.string(from: startDate),
//            endTime: dateFormatterISO.string(from: endDate),
//            relatedItemId: item.id,
//            ownerId: ownerUid,
//            borrowerId: borrowerUid,
//            requestStatus: "pending"
//        )
//
//        let transactionRef = dbRef.child("transactions").child(transactionId)
//        do {
//            let transactionData = try JSONEncoder().encode(newTransaction)
//            let transactionDict = try JSONSerialization.jsonObject(with: transactionData, options: []) as? [String: Any]
//            
//            guard let dict = transactionDict else {
//                alertMessage = "Error: Could not prepare transaction data."; requestSuccessful = false; showAlert = true; return
//            }
//            transactionRef.setValue(dict) { error, _ in
//                if let error = error {
//                    alertMessage = "Failed to submit request: \(error.localizedDescription)"; requestSuccessful = false
//                } else {
//                    alertMessage = "Request submitted successfully!"; requestSuccessful = true
//                }
//                showAlert = true
//            }
//        } catch {
//            alertMessage = "Error encoding transaction: \(error.localizedDescription)"; requestSuccessful = false; showAlert = true
//        }
//    }
//}

struct RequestView: View {
    let item: DisplayItem
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel // Use placeholder for preview, real one in app

    private var dbRef: DatabaseReference = Database.database().reference()

    private var dateFormatterISO: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    private var humanReadableDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let distantFuture = Calendar.current.date(byAdding: .year, value: 5, to: today)!
        return today...distantFuture
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var requestSuccessful = false
    @State private var isSubmitting = false // To disable button during submission

    init(item: DisplayItem) {
        self.item = item
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Borrow Details")
                    .font(.largeTitle).fontWeight(.bold).padding(.top, 20)

                HStack(spacing: 15) {
                    // Item Image and Info
                    if UIImage(named: item.imageName) != nil {
                        Image(item.imageName).resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(10).clipped()
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 80, height: 80).cornerRadius(10).overlay(Text("No\nImage").font(.caption).multilineTextAlignment(.center))
                    }
                    VStack(alignment: .leading) {
                        Text(item.name).font(.title2).fontWeight(.semibold).lineLimit(2)
                        Text(item.rentalPrice).font(.headline).foregroundColor(.gray)
                    }
                    Spacer()
                }.padding(.horizontal)
                Divider()

                // Start Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Start Date").font(.headline)
                    HStack {
                        Text(monthYearFormatter.string(from: startDate)).font(.title3).bold()
                        Spacer()
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate), newDate >= dateRange.lowerBound { startDate = newDate }
                        }) { Image(systemName: "chevron.left") }
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate), newDate <= dateRange.upperBound { startDate = newDate }
                        }) { Image(systemName: "chevron.right") }
                    }.padding(.horizontal, 5)
                    DatePicker("Start Date", selection: $startDate, in: dateRange, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle()).labelsHidden()
                        .onChange(of: startDate) { newStartDate in if newStartDate > endDate { endDate = newStartDate } }
                }.padding(.horizontal)
                Divider()

                // End Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select End Date").font(.headline)
                    HStack {
                        Text(monthYearFormatter.string(from: endDate)).font(.title3).bold()
                        Spacer()
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate), newDate >= max(startDate, dateRange.lowerBound) { endDate = newDate }
                        }) { Image(systemName: "chevron.left") }
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: endDate), newDate <= dateRange.upperBound { endDate = newDate }
                        }) { Image(systemName: "chevron.right") }
                    }.padding(.horizontal, 5)
                    DatePicker("End Date", selection: $endDate, in: max(startDate, dateRange.lowerBound)...dateRange.upperBound, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle()).labelsHidden()
                }.padding(.horizontal)
                Spacer(minLength: 30)

                Button(action: submitTransaction) {
                    if isSubmitting {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Request")
                    }
                }
                .font(.title2).fontWeight(.bold).foregroundColor(.white).padding()
                .frame(maxWidth: .infinity).background(isSubmitting ? Color.gray : Color.orange).cornerRadius(12)
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                .disabled(isSubmitting)
                .padding(.horizontal).padding(.bottom, 20)
            }
        }
        .navigationTitle("Borrow Details").navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(requestSuccessful ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if requestSuccessful {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }

    func submitTransaction() {
        isSubmitting = true
        guard let borrowerUid = authViewModel.userSession?.uid else {
            alertMessage = "Error: You must be logged in to make a request."
            requestSuccessful = false; showAlert = true; isSubmitting = false; print(alertMessage); return
        }
        guard let ownerUid = item.ownerUid, !ownerUid.isEmpty else {
            alertMessage = "Error: Item owner information is missing."
            requestSuccessful = false; showAlert = true; isSubmitting = false; print(alertMessage); return
        }
        if endDate < startDate {
            alertMessage = "Error: End date cannot be before start date."
            requestSuccessful = false; showAlert = true; isSubmitting = false; return
        }

        let transactionId = UUID().uuidString
        let newTransaction = Transaction(
            id: transactionId,
            transactionDate: dateFormatterISO.string(from: Date()),
            startTime: dateFormatterISO.string(from: startDate),
            endTime: dateFormatterISO.string(from: endDate),
            relatedItemId: item.id,
            ownerId: ownerUid,
            borrowerId: borrowerUid,
            requestStatus: "pending"
        )

        let transactionRef = dbRef.child("transactions").child(transactionId)
        
        do {
            let transactionData = try JSONEncoder().encode(newTransaction)
            let transactionDict = try JSONSerialization.jsonObject(with: transactionData, options: []) as? [String: Any]
            
            guard let dict = transactionDict else {
                alertMessage = "Error: Could not prepare transaction data."; requestSuccessful = false; showAlert = true; isSubmitting = false; return
            }

            transactionRef.setValue(dict) { [self] error, _ in // Explicit self capture
                if let error = error {
                    self.alertMessage = "Failed to submit request: \(error.localizedDescription)"; self.requestSuccessful = false
                    self.isSubmitting = false
                } else {
                    // Transaction saved, now create and save InboxMessage for the owner
                    self.createAndSaveInboxMessage(for: newTransaction, ownerId: ownerUid, borrower: authViewModel.userSession)
                    // Note: alertMessage and requestSuccessful for the overall process
                    // will be set inside createAndSaveInboxMessage or after its completion.
                    // For now, we assume success of transaction posting means we proceed.
                }
                // Defer showing alert until inbox message is also handled or if transaction fails.
                // self.showAlert = true // Moved to createAndSaveInboxMessage completion
            }
        } catch {
            alertMessage = "Error encoding transaction: \(error.localizedDescription)"; requestSuccessful = false; showAlert = true; isSubmitting = false
        }
    }

    func createAndSaveInboxMessage(for transaction: Transaction, ownerId: String, borrower: UserSession?) {
        let messageId = UUID().uuidString
        let borrowerNameOrEmail = borrower?.displayName ?? borrower?.email ?? "A user"

        let inboxMessage = InboxMessage(
            id: messageId,
            dateLine: "\(borrowerNameOrEmail) requested to borrow '\(item.name)'",
            type: "request_received",
            showsRejectButton: true, // Owner can accept/reject
            relatedTransactionId: transaction.id,
            timestamp: Date().timeIntervalSince1970,
            isRead: false,
            lenderName: borrowerNameOrEmail, // From borrower's perspective, this is the "other party"
            itemName: item.name
        )

        let inboxMessageRef = dbRef.child("inbox_messages").child(ownerId).child(messageId)
        do {
            let messageData = try JSONEncoder().encode(inboxMessage)
            let messageDict = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any]

            guard let dict = messageDict else {
                self.alertMessage = "Request submitted, but failed to create notification data for owner."; self.requestSuccessful = true; // Transaction was successful
                self.showAlert = true; self.isSubmitting = false; return
            }

            inboxMessageRef.setValue(dict) { [self] error, _ in // Explicit self capture
                if let error = error {
                    self.alertMessage = "Request submitted, but failed to notify owner: \(error.localizedDescription)"
                    self.requestSuccessful = true; // Transaction was successful
                } else {
                    self.alertMessage = "Request submitted successfully and owner notified!"
                    self.requestSuccessful = true
                }
                self.showAlert = true
                self.isSubmitting = false
            }
        } catch {
            self.alertMessage = "Request submitted, but error encoding notification: \(error.localizedDescription)"
            self.requestSuccessful = true; // Transaction was successful
            self.showAlert = true
            self.isSubmitting = false
        }
    }
}

//// MARK: - Preview Provider
//struct RequestView_Previews: PreviewProvider {
//    static var sampleItem1 = DisplayItem(
//        id: "item001", name: "Vintage Camera Lens", imageName: "DummyProduct",
//        rentalPrice: "Rp 50.000 /day", categoryId: 2,
//        description: "A classic 50mm f/1.8 lens, perfect for portraits and low light photography. Excellent condition.",
//        isAvailable: true, ownerUid: "owner123_firebase_uid"
//    )
//    static var sampleItem2 = DisplayItem(
//        id: "item002", name: "Camping Tent - 4 Person", imageName: "tent_preview",
//        rentalPrice: "Rp 75.000 /day", categoryId: 5,
//        description: "Spacious and durable 4-person tent, ideal for family camping trips. Weatherproof and easy to set up.",
//        isAvailable: false, ownerUid: "owner456_firebase_uid"
//    )
//
//    static var previews: some View {
//        let authViewModelPlaceholder = AuthViewModel()
//        
//        NavigationView {
//            RequestView(item: sampleItem1)
//                .environmentObject(authViewModelPlaceholder)
//        }
//        .previewDisplayName("Request View - Item 1")
//
//        NavigationView {
//            RequestView(item: sampleItem2)
//                .environmentObject(authViewModelPlaceholder)
//        }
//        .previewDisplayName("Request View - Item 2 (Dark)")
//        .preferredColorScheme(.dark)
//        
//        NavigationView {
//            RequestView(item: DisplayItem(
//                id: "item003",
//                name: "Professional Grade Electric Guitar with Mahogany Body and Maple Neck",
//                imageName: "guitar_preview", rentalPrice: "Rp 120.000 /day", categoryId: 6,
//                description: "High-end electric guitar with amazing tone and playability. Comes with a hard case.",
//                isAvailable: true, ownerUid: "owner789_firebase_uid"
//            ))
//            .environmentObject(authViewModelPlaceholder)
//        }
//        .previewDisplayName("Request View - Long Name")
//    }
//}

struct RequestView_Previews: PreviewProvider {
    static var sampleItem1 = DisplayItem(
        id: "item001", name: "Vintage Camera Lens", imageName: "DummyProduct",
        rentalPrice: "Rp 50.000 /day", categoryId: 2,
        description: "A classic 50mm f/1.8 lens...",
        isAvailable: true, ownerUid: "owner123_firebase_uid"
    )
    static var sampleItem2 = DisplayItem(
        id: "item002", name: "Camping Tent - 4 Person", imageName: "tent_preview",
        rentalPrice: "Rp 75.000 /day", categoryId: 5,
        description: "Spacious and durable 4-person tent...",
        isAvailable: false, ownerUid: "owner456_firebase_uid"
    )

    static var previews: some View {
        let authViewModelPlaceholder = AuthViewModel()
        
        NavigationView {
            RequestView(item: sampleItem1)
                .environmentObject(authViewModelPlaceholder)
        }
        .previewDisplayName("Request View - Item 1")

        NavigationView {
            RequestView(item: sampleItem2)
                .environmentObject(authViewModelPlaceholder)
        }
        .previewDisplayName("Request View - Item 2 (Dark)")
        .preferredColorScheme(.dark)
        
        NavigationView {
            RequestView(item: DisplayItem(
                id: "item003",
                name: "Professional Grade Electric Guitar...",
                imageName: "guitar_preview", rentalPrice: "Rp 120.000 /day", categoryId: 6,
                description: "High-end electric guitar...",
                isAvailable: true, ownerUid: "owner789_firebase_uid"
            ))
            .environmentObject(authViewModelPlaceholder)
        }
        .previewDisplayName("Request View - Long Name")
    }
}
