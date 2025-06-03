// mhadiwidjaja/sparetrousers/SpareTrousers-a561ff476a166c8bc23b8d4c7bfb8fb50ec5c30f/SpareTrousers/View/MyRentalsView.swift

import SwiftUI
import FirebaseAuth

struct MyRentalsView: View {
    // HomeViewModel is still needed for AddItemsView context (passed via environment)
    // and to initialize MyRentalViewModel.
    @EnvironmentObject private var homeVM_env: HomeViewModel // Renamed to avoid conflict if needed, though initializer takes precedence.
                                                          // This is primarily for the AddItemsView sheet.

    // New StateObject for MyRentalViewModel, initialized via the init method.
    @StateObject private var myRentalVM: MyRentalViewModel

    @State private var isPresentingAddItem = false

    // corner radius for the white content
    let topSectionCornerRadius: CGFloat = 18
    
    // Initializer to set up MyRentalViewModel with HomeViewModel
    init(homeViewModel: HomeViewModel) { // This initializer is called by HomeView
        _myRentalVM = StateObject(wrappedValue: MyRentalViewModel(homeViewModel: homeViewModel))
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
                        // My Borrowing (unchanged as per request)
                        Text("My Borrowing")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appBlack)
                            .padding(.leading, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(0..<5) { _ in RentalRow() } // Placeholder for borrowing
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 250)
                        .background(Color.appWhite)
                        .cornerRadius(10)

                        // My Lending - Updated
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
                                  .environmentObject(homeVM_env) // AddItemsView still uses HomeViewModel from environment
                            }
                        }
                        .padding(.horizontal, 5)

                        ScrollView {
                            // Use items from MyRentalViewModel
                            if myRentalVM.myLendingItems.isEmpty {
                                Text("You haven't listed any items for lending yet.")
                                    .foregroundColor(.appOffGray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 2) {
                                    // --- MODIFICATION FOR NAVIGATION ---
                                    ForEach(myRentalVM.myLendingItems) { item in
                                        NavigationLink(destination: OwnedItemDetailView(item: item)) { // Wrap RentalRow
                                            RentalRow(item: item, isBorrowing: false)
                                        }
                                        // To make it look less like a default blue link, you might consider
                                        // .buttonStyle(PlainButtonStyle()) if the default styling is an issue,
                                        // though often the row itself being tappable is fine.
                                    }
                                    // --- END OF MODIFICATION ---
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
    var isBorrowing: Bool = true

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
                    Text("Lender: \(item?.ownerUid ?? "-")")
                        .font(.subheadline)
                        .foregroundColor(.appOffGray)
                    Text("Rented until: [Date Placeholder]") // Placeholder
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
                        .fill(isBorrowing ? Color.red : ((item?.isAvailable ?? false) ? Color.green : Color.gray))
                        .frame(width: 10, height: 10)
                    
                    // --- MODIFIED STATUS TEXT LOGIC TO FIX 'buildExpression' ERROR ---
                    if isBorrowing {
                        Text("Status: Rent due today") // Placeholder for borrowing status
                            .font(.caption2)
                            .foregroundColor(.appBlack)
                    } else {
                        // For "My Lending" items
                        if item?.isAvailable ?? false {
                            Text("Status: Available") // User's requested text
                                .font(.caption2)
                                .foregroundColor(.appBlack)
                        } else {
                            Text("Status: Unavailable")
                                .font(.caption2)
                                .foregroundColor(.appBlack)
                        }
                    }
                    // --- END OF MODIFIED STATUS TEXT LOGIC ---
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
        // Create a HomeViewModel instance for the preview
        let previewHomeVM = HomeViewModel()
        // Optionally populate previewHomeVM.allFetchedItems with sample data if needed for thorough previewing
        // e.g., previewHomeVM.allFetchedItems = [ ... some DisplayItems ... ]
        // This allows MyRentalViewModel to filter something during the preview.

        MyRentalsView(homeViewModel: previewHomeVM) // Pass it to the initializer
            .environmentObject(previewHomeVM) // Provide it to the environment for AddItemsView sheet
            .environmentObject(AuthViewModel()) // If any part of MyRentalsView or its children needs AuthViewModel
    }
}
