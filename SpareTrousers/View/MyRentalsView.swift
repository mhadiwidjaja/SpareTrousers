//
//  MyRentalsView.swift
//  SpareTrousers
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct MyRentalsView: View {
    // corner radius for the scrollable content
    let topSectionCornerRadius: CGFloat = 18

    var body: some View {
        VStack(spacing: 0) {
            // ───── BLUE HEADER ─────
            VStack(spacing: 10) {
                Spacer().frame(height: 20)   
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
                RoundedCorner(radius: 18, corners: [.bottomLeft, .bottomRight])
            )

            // ───── CONTENT ─────
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Borrowing section
                    Text("My Borrowing")
                        .font(.custom("MarkerFelt-Wide", size: 24))
                        .foregroundColor(.appBlack)
                        .padding(.leading, 5)

                    ForEach(0..<3) { _ in
                        RentalRow()
                    }

                    // Lending section
                    HStack {
                        Text("My Lending")
                            .font(.custom("MarkerFelt-Wide", size: 24))
                            .foregroundColor(.appBlack)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.appBlack)
                        }
                    }
                    .padding(.horizontal, 5)

                    ForEach(0..<2) { _ in
                        RentalRow()
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .background(Color.appWhite)
            .clipShape(
                RoundedCorner(radius: topSectionCornerRadius,
                              corners: [.topLeft, .topRight])
            )
            .ignoresSafeArea(edges: .bottom)  // extend under home‐indicator
        }
        .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
    }
}

struct RentalRow: View {
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
                    .font(.headline)
                    .foregroundColor(.appBlack)

                Text("Lender: Jimbo")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                Text("Rented until 18-06-2025")
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text("Status: Rent due today")
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
