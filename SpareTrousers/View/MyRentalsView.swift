//
//  MyRentalsView.swift
//  SpareTrousers
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct MyRentalsView: View {
    // corner radius for the white content
    let topSectionCornerRadius: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ───── BLUE HEADER (UNCHANGED) ─────
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
                    RoundedCorner(radius: 18, corners: [.bottomLeft, .bottomRight])
                )
                .offset(y: -86)

                // ───── WHITE ROUNDED CONTENT ─────
                ZStack(alignment: .top) {
                    // full-height white background with only top corners rounded
                    Color.appWhite
                        .clipShape(
                            RoundedCorner(
                                radius: topSectionCornerRadius,
                                corners: [.topLeft, .topRight]
                            )
                        )

                    // your content
                    VStack(spacing: 16) {
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

                        HStack {
                            Text("My Lending")
                                .font(.custom("MarkerFelt-Wide", size: 24))
                                .foregroundColor(.appBlack)
                            Spacer()
                            Button { } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.appBlack)
                            }
                        }
                        .padding(.horizontal, 5)

                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(0..<4) { _ in RentalRow(isBorrowing: false) }
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
                // ← here we let the ZStack fill the rest of the screen
                .frame(width: geo.size.width, height: geo.size.height + 86)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)

            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
        }
    }
}

struct RentalRow: View {
    var isBorrowing: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Image("DummyProduct")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text("Orange and Blue Trousers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appBlack)

                Text(isBorrowing ? "Lender: Jimbo" : "Borrower: Jimbo")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                Text("Rented until 18-06-2025")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                HStack(spacing: 4) {
                    Circle()
                        .fill(isBorrowing ? Color.red : Color.green)
                        .frame(width: 10, height: 10)
                    Text(isBorrowing
                         ? "Status: Rent due today"
                         : "Status: Active")
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
    }
}
