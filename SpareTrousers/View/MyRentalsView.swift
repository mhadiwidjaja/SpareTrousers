// mhadiwidjaja/sparetrousers/SpareTrousers-a561ff476a166c8bc23b8d4c7bfb8fb50ec5c30f/SpareTrousers/View/MyRentalsView.swift

import SwiftUI
import FirebaseAuth

struct MyRentalsView: View {
    @EnvironmentObject private var homeVM_env: HomeViewModel
    @EnvironmentObject private var authVM_env: AuthViewModel
    @StateObject private var myRentalVM: MyRentalViewModel
    @State private var isPresentingAddItem = false
    let topSectionCornerRadius: CGFloat = 18
    
    init(homeViewModel: HomeViewModel, authViewModel: AuthViewModel) {
        _myRentalVM = StateObject(
            wrappedValue: MyRentalViewModel(
                homeViewModel: homeViewModel,
                authViewModel: authViewModel
            )
        )
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ───── BLUE HEADER ─────
                VStack(spacing: 10) {
                    Spacer().frame(height: 80)
                    HStack {
                        Text("My Rentals")
                            .font(.custom("MarkerFelt-Wide", size: 36))
                            .foregroundColor(.appWhite)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                            .shadow(color: .appBlack, radius: 1)
                        Spacer()
                        Image("SpareTrousers")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .background(Color.appBlue.edgesIgnoringSafeArea(.top))
                .clipShape(
                    RoundedCorner(radius: topSectionCornerRadius,
                                  corners: [.bottomLeft, .bottomRight])
                )
                .offset(y: -86)

                // ───── WHITE ROUNDED CONTENT ─────
                ZStack(alignment: .top) {
                    Color.appWhite
                        .clipShape(
                            RoundedCorner(
                                radius: topSectionCornerRadius,
                                corners: [.topLeft, .topRight]
                            )
                        )

                    VStack(spacing: 16) {
                        Text("My Borrowing")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appBlack)
                            .padding(.leading, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView {
                            if myRentalVM.isLoading && myRentalVM.myBorrowedEntries.isEmpty {
                                ProgressView("Loading borrowed items...")
                                    .padding()
                            } else if let errorMessage = myRentalVM.errorMessage {
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .padding()
                            } else if myRentalVM.myBorrowedEntries.isEmpty {
                                Text(
                                    "You are not currently borrowing any items."
                                )
                                .foregroundColor(.appOffGray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 2) {
                                    // Updated ForEach to pass lenderDisplayName
                                    ForEach(
                                        myRentalVM.myBorrowedEntries,
                                        id: \.item.id
                                    ) { entry in
                                        NavigationLink(
                                            destination: BorrowedItemDetailView(item: entry.item, transaction: entry.transaction) // <<-- Changed line
                                        ) {
                                            RentalRow(item: entry.item,
                                                      transaction: entry.transaction,
                                                      lenderDisplayName: entry.lenderDisplayName, // Pass display name
                                                      isBorrowing: true)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxHeight: 250)
                        .background(Color.appWhite)
                        .cornerRadius(10)

                        HStack {
                            Text("My Lending")
                                .font(.custom("MarkerFelt-Wide", size: 24))
                                .foregroundColor(.appBlack)
                            Spacer()
                            Button {
                                isPresentingAddItem = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.appBlack)
                            }
                            .sheet(isPresented: $isPresentingAddItem) {
                                AddItemsView()
                                    .environmentObject(
                                        homeVM_env
                                    )
                            }
                        }
                        .padding(.horizontal, 5)

                        ScrollView {
                            if myRentalVM.isLoading && myRentalVM.myLendingItems.isEmpty {
                                ProgressView("Loading your items...")
                            } else if myRentalVM.myLendingItems.isEmpty {
                                Text(
                                    "You haven't listed any items for lending yet."
                                )
                                .foregroundColor(.appOffGray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 2) {
                                    ForEach(myRentalVM.myLendingItems) { item in
                                        NavigationLink(
                                            destination: OwnedItemDetailView(
                                                item: item
                                            )
                                        ) {
                                            RentalRow(
                                                item: item,
                                                isBorrowing: false
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxHeight: 250)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .frame(width: geo.size.width, height: geo.size.height + 86)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
        }
    }
}

struct RentalRow: View {
    var item: DisplayItem? = nil
    var transaction: Transaction? = nil
    var lenderDisplayName: String? = nil
    var isBorrowing: Bool = true
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isoDateFormatter: ISO8601DateFormatter {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
            return formatter
        }

    private func formatTransactionDate(_ dateString: String?) -> String {
            guard let dateStr = dateString, let date = isoDateFormatter.date(from: dateStr) else {
                let simplerFormatter = ISO8601DateFormatter()
                simplerFormatter.formatOptions = [.withInternetDateTime, .withTimeZone]
                if let simplerDateStr = dateString, let simplerDate = simplerFormatter.date(from: simplerDateStr) {
                    return dateFormatter.string(from: simplerDate)
                }
                return "N/A"
            }
            return dateFormatter.string(from: date)
        }

    var body: some View {
        HStack(spacing: 12) {
            Image(item?.imageName ?? "DummyProduct")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item?.name ?? "Item Name")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appBlack)

                if isBorrowing {
                    Text("Lender: \(lenderDisplayName ?? item?.ownerUid ?? "-")")
                        .font(.subheadline)
                        .foregroundColor(.appOffGray)
                    Text(
                        "Rented until: \(formatTransactionDate(transaction?.endTime))"
                    )
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)
                } else {
                    Text("Borrower: -")
                        .font(.subheadline)
                        .foregroundColor(.appOffGray)
                    Text("Rental Price: \(item?.rentalPrice ?? "-")")
                        .font(.subheadline)
                        .foregroundColor(.appOffGray)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(
                            isBorrowing ? Color.red : (
                                (
                                    item?.isAvailable ?? false
                                ) ? Color.green : Color.gray
                            )
                        )
                        .frame(width: 10, height: 10)
                    if isBorrowing {
                        Text(
                            "Status: Rent due today"
                        )
                        .font(.caption2)
                        .foregroundColor(.appBlack)
                    } else {
                        if item?.isAvailable ?? false {
                            Text("Status: Available")
                                .font(.caption2)
                                .foregroundColor(.appBlack)
                        } else {
                            Text("Status: Unavailable")
                                .font(.caption2)
                                .foregroundColor(.appBlack)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.appBlack)
        }
        .padding(10)
        .background(Color.appWhite)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}



struct MyRentalsView_Previews: PreviewProvider {
    static var previews: some View {
        let previewHomeVM = HomeViewModel()

        MyRentalsView(
            homeViewModel: previewHomeVM, authViewModel: AuthViewModel()
        )
        .environmentObject(
            previewHomeVM
        )
        .environmentObject(
            AuthViewModel()
        )
    }
}
