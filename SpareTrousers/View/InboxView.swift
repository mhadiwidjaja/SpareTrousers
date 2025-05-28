//
//  InboxView.swift
//  SpareTrousers
//
//  Created by student on 28/05/25.
//

import SwiftUI

struct InboxView: View {
    // corner radius for the white content
    let topSectionCornerRadius: CGFloat = 18

    // placeholder messages
    private let requests: [InboxRequest] = [
        .init(
            message: #"Jimbo sent a request to borrow “Orange and Blue Trousers”"#,
            dateLine: "16-05-2025 | 20-05-2025",
            showsReject: true
        ),
        .init(
            message: #"It’s time to pick up “Orange and Blue Trousers” from Jimbo"#,
            dateLine: "18-05-2025",
            showsReject: false
        )
    ]

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

                // ───── WHITE CONTENT AREA ─────
                ZStack(alignment: .top) {
                    Color.appWhite
                        .clipShape(
                            RoundedCorner(
                                radius: topSectionCornerRadius,
                                corners: [.topLeft, .topRight]
                            )
                        )

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(requests) { req in
                                InboxRow(request: req)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height + 86)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: -68)
            }
            .background(Color.appOffWhite.edgesIgnoringSafeArea(.all))
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
    let request: InboxRequest

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(request.message)
                    .font(.body)
                    .foregroundColor(.appBlack)
                    .fixedSize(horizontal: false, vertical: true)

                Text(request.dateLine)
                    .font(.caption)
                    .foregroundColor(.appOffGray)
            }

            Spacer()

            HStack(spacing: 12) {
                // Accept
                Button {
                    // handle accept
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .heavy))
                        .frame(width: 32, height: 32)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Optional reject
                if request.showsReject {
                    Button {
                        // handle reject
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .heavy))
                            .frame(width: 32, height: 32)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.appWhite)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.appBlack, lineWidth: 2)
        )
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
