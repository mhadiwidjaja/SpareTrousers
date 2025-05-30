//
//  ItemDetailView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct ItemDetailView: View {
    // State for the current page in the image carousel
    @State private var currentPage = 0

    // Placeholder for image names. Replace with your actual image assets.
    let productImages = ["DummyProduct", "SpareTrousers", "DummyProduct"]

    // Placeholder for review data
    let sampleReviews = [
        Review(reviewerName: "Jimbo",
               reviewText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas.",
               rating: 4)
    ]

    // Corner radius for the white info panel
    private let infoCornerRadius: CGFloat = 18

    var body: some View {
        ZStack(alignment: .bottom) {
            // base off-white (for the header gap)
            Color.appOffWhite.edgesIgnoringSafeArea(.all)

            // full-screen white, but pushed down so it only shows under the panel
            Color.appWhite
                .offset(y: 290)         // 350 header height − 60 overlap
                .edgesIgnoringSafeArea(.bottom)

            // ───── MAIN SCROLLING CONTENT ─────
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ───── BLUE HEADER WITH CAROUSEL ─────
                    ZStack(alignment: .bottom) {
                        Color.appBlue
                            .frame(height: 350)
                            .clipShape(
                                RoundedCorner(radius: infoCornerRadius,
                                              corners: [.bottomLeft, .bottomRight])
                            )
                            .edgesIgnoringSafeArea(.top)

//                        ImageCarouselView(images: productImages,
//                                          currentPage: $currentPage)
//                            .frame(height: 60)
//                            .padding(.bottom, 20)
                           ImageCarouselView(images: productImages,
                                             currentPage: $currentPage)
                               .frame(width: UIScreen.main.bounds.width * 0.8,
                                      height: 250)
                               .padding(.bottom, 20)
                    }
                    .offset(y: -86)

                    // ───── WHITE INFO PANEL ─────
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text("Orange and Blue Trousers")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appBlack)

                        // Rating + Availability
                        HStack(spacing: 12) {
                            RatingView(rating: 4.8, reviewCount: 69)
                            AvailabilityView(isAvailable: true)
                            Spacer()
                        }

                        // Price
                        Text("Rp 20.000 /day")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.appBlack)

                        // Description section
                        SectionView(title: "Description") {
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas. In vitae ipsum ac dui facilisis tristique ac quis ligula. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque suscipit et turpis vel placerat. Aliquam non lectus efficitur, sagittis quam id, pulvinar mi.")
                                .font(.body)
                                .foregroundColor(.appBlack.opacity(0.7))
                                .lineSpacing(5)
                        }

                        // Reviews section
                        SectionView(title: "Reviews", showAddButton: true) {
                            if sampleReviews.isEmpty {
                                Text("No reviews yet.")
                                    .font(.body)
                                    .foregroundColor(.appBlack.opacity(0.7))
                            } else {
                                ForEach(sampleReviews) { review in
                                    ReviewCardView(review: review)
                                }
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding()
                    .background(Color.appWhite)
                    .clipShape(
                        RoundedCorner(
                            radius: infoCornerRadius,
                            corners: [.topLeft, .topRight]
                        )
                    )
                    .offset(y: -60)
                }
            }

            // ───── BORROW BUTTON ─────
            BorrowButton()
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
    }
}

// ... the rest of your subviews unchanged:

struct ImageCarouselView: View {
    let images: [String]
    @Binding var currentPage: Int

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<images.count, id: \.self) { index in

                               Image(images[index])
                                   .resizable()
                                   .scaledToFit()
                                   .cornerRadius(12)
                                   .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct RatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
                .fontWeight(.semibold)
            Text("\(reviewCount) reviews")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct AvailabilityView: View {
    let isAvailable: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isAvailable ? .green : .red)
                .frame(width: 10, height: 10)
            Text(isAvailable ? "Available" : "Unavailable")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct SectionView<Content: View>: View {
    let title: String
    var showAddButton: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if showAddButton {
                    Image(systemName: "plus")
                        .font(.headline)
                }
            }
            content
        }
    }
}

struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let reviewText: String
    let rating: Int
}

struct ReviewCardView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("From \(review.reviewerName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                    }
                }
            }
            Text(review.reviewText)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct BorrowButton: View {
    var body: some View {
        Button {
            // handle borrow action
        } label: {
            Text("Borrow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(12)
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView()
            .preferredColorScheme(.light)
    }
}
