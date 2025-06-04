//
//  BorrowedItemDetailView.swift
//  SpareTrousers
//
//  Created by Student on 04/06/25.
//

import SwiftUI
import Combine

struct BorrowedItemDetailView: View {
    let item: DisplayItem
    let transaction: Transaction
    
    @State private var currentPage = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var lenderDisplayName: String = "Loading..."
    @State private var cancellables = Set<AnyCancellable>()

    var productImages: [String] {
        var images = [item.imageName]
        images.append(contentsOf: ["SpareTrousers", "DummyProduct"])
        return images.filter { !$0.isEmpty }.removingDuplicates()
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var transactionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }

    private func formatDisplayDate(_ dateString: String?, using specificFormatter: DateFormatter) -> String {
        guard let dateStr = dateString else { return "N/A" }
        if let date = isoDateFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        let fallbackIsoFormatter = ISO8601DateFormatter()
        fallbackIsoFormatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        if let date = fallbackIsoFormatter.date(from: dateStr) {
            return specificFormatter.string(from: date)
        }
        print("Warning: Could not parse date string: \(dateStr)")
        return "N/A"
    }

    private let infoCornerRadius: CGFloat = 18

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appOffWhite.edgesIgnoringSafeArea(.all)
            Color.appWhite
                .offset(y: 290)
                .edgesIgnoringSafeArea(.bottom)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ItemDetailHeaderView(
                        productImages: productImages,
                        currentPage: $currentPage,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -86)

                    VStack(alignment: .leading, spacing: 16) {
                        ItemInfoPanelView(
                            item: item,
                            sampleReviews: [],
                            infoCornerRadius: infoCornerRadius
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rental Details")
                                .font(.title2).fontWeight(.bold)
                                .padding(.bottom, 4)
                            
                            InfoRow(label: "Borrowed On:", value: formatDisplayDate(transaction.transactionDate, using: transactionDateFormatter))
                            InfoRow(label: "Rental Starts:", value: formatDisplayDate(transaction.startTime, using: dateFormatter))
                            InfoRow(label: "Rental Ends:", value: formatDisplayDate(transaction.endTime, using: dateFormatter))
                            InfoRow(label: "Lender:", value: lenderDisplayName)
                        }
                        .padding()
                        .background(Color.appWhite)
                        .cornerRadius(infoCornerRadius)
                        .padding(.top, -infoCornerRadius)

                        Spacer(minLength: 20)
                    }
                    .offset(y: -60)
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchLenderName()
        }
    }
    
    private func fetchLenderName() {
        guard let ownerUid = item.ownerUid, !ownerUid.isEmpty else {
            self.lenderDisplayName = "N/A"
            return
        }
        
        authViewModel.fetchUserDisplayName(uid: ownerUid) //
            .receive(on: DispatchQueue.main)
            .sink { fetchedName in
                if let name = fetchedName, !name.isEmpty {
                    self.lenderDisplayName = name
                } else {
                    self.lenderDisplayName = "Lender (\(ownerUid.prefix(6))...)"
                }
            }
            .store(in: &cancellables)
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 16
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
    }
}

// Extension to remove duplicates from an array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}


// MARK: - Preview
struct BorrowedItemDetailView_Previews: PreviewProvider {
    static var sampleItem = DisplayItem(
        id: "borrowedItem001",
        name: "Borrowed Vintage Camera",
        imageName: "DummyProduct",
        rentalPrice: "Rp 50.000 /day",
        categoryId: 2,
        description: "A classic 50mm f/1.8 lens, currently being borrowed. Perfect for portraits and low light photography.",
        isAvailable: false,
        ownerUid: "ownerLender123_firebase_uid"
    )
    
    static var sampleTransaction = Transaction(
        id: "txnBorrow123",
        transactionDate: "2025-06-01T10:00:00Z",
        startTime: "2025-06-05T14:00:00Z",
        endTime: "2025-06-10T18:00:00Z",
        relatedItemId: "borrowedItem001",
        ownerId: "ownerLender123_firebase_uid",
        borrowerId: "currentUserBorrower456",
        requestStatus: "approved"
    )

    static var previews: some View {
        let mockAuthViewModel = AuthViewModel()

        NavigationView {
            BorrowedItemDetailView(item: sampleItem, transaction: sampleTransaction)
        }
        .environmentObject(mockAuthViewModel)
        .environmentObject(HomeViewModel())
    }
}
