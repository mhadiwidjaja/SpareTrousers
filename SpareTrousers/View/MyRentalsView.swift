//
//  MyRentalsView.swift
//  SpareTrousers
//
//  Created by student on 27/05/25.
//

import SwiftUI
import FirebaseAuth

struct MyRentalsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @State private var isPresentingAddItem = false

    // corner radius for the white content
    let topSectionCornerRadius: CGFloat = 18

    /// Only the current user's available lending items
    private var myLendingItems: [DisplayItem] {
        let uid = Auth.auth().currentUser?.uid ?? ""
        return homeVM
            .displayedNearYouItems    // or, if you want _all_ items, expose a `@Published var allItems` in VM
            .filter { $0.ownerUid == uid && $0.status }
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
                        // My Borrowing (unchanged)
                        Text("My Borrowing")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appBlack)
                            .padding(.leading, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(0..<5) { _ in RentalRow() }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 250)
                        .background(Color.appWhite)
                        .cornerRadius(10)

                        // My Lending
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
                                  .environmentObject(homeVM)
                            }
                        }
                        .padding(.horizontal, 5)

                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(myLendingItems) { item in
                                    RentalRow(item: item, isBorrowing: false)
                                }
                            }
                            .padding(.horizontal)
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

// RentalRow unchanged, except now accepts an optional DisplayItem
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

                Text(isBorrowing
                     ? "Lender: \(item?.ownerUid ?? "-")"
                     : "Borrower: \(item?.ownerUid ?? "-")")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                Text("Rented until \(item?.rentalPrice ?? "-")")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                HStack(spacing: 4) {
                    Circle()
                        .fill(isBorrowing ? Color.red : Color.green)
                        .frame(width: 10, height: 10)
                    Text(isBorrowing ? "Status: Rent due today" : "Status: Active")
                        .font(.caption2)
                        .foregroundColor(.appBlack)
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
        MyRentalsView()
          .environmentObject(HomeViewModel())
    }
}
