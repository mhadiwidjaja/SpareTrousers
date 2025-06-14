//
//  ItemDetailView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let reviewText: String
    let rating: Int
}

struct ItemDetailView: View {
    let item: DisplayItem
    @State private var currentPage = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var productImages: [String] {
        var images = [item.imageName]
        images.append(contentsOf: ["SpareTrousers", "DummyProduct"])
        return images.filter { !$0.isEmpty }
    }

    let sampleReviews = [
        Review(reviewerName: "Jimbo",
               reviewText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas.",
               rating: 4)
    ]

    private let infoCornerRadius: CGFloat = 18

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appOffWhite.edgesIgnoringSafeArea(.all)

            if horizontalSizeClass == .compact {
                            Color.appWhite
                                .offset(y: 290)
                                .edgesIgnoringSafeArea(.bottom)
                        } else {
                            Color.appWhite
                                .edgesIgnoringSafeArea([.horizontal, .bottom])
                        }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ItemDetailHeaderView(
                        productImages: productImages,
                        currentPage: $currentPage,
                        infoCornerRadius: infoCornerRadius,
                        horizontalSizeClass: horizontalSizeClass
                    )
                    .offset(y: horizontalSizeClass == .compact ? -86 : 0)

                    ItemInfoPanelView(
                        item: item,
                        sampleReviews: sampleReviews,
                        infoCornerRadius: infoCornerRadius,
                        horizontalSizeClass: horizontalSizeClass
                    )
                    .offset(y: horizontalSizeClass == .compact ? -60 : 0)
                                        .padding(.horizontal, horizontalSizeClass == .regular ? 20 : 0)
                                        .frame(maxWidth: horizontalSizeClass == .regular ? 700 : .infinity, alignment: .center)
                }
            }

            BorrowButtonModified(item: item)
                .padding(.horizontal, horizontalSizeClass == .compact ? nil : 40)
                                .padding(.bottom, safeAreaBottomInset())
                                .frame(maxWidth: horizontalSizeClass == .regular ? 500 : .infinity)
                                .padding(.horizontal, horizontalSizeClass == .regular ? (UIScreen.main.bounds.width - 500) / 2 : 0)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 16
    }
}

struct ItemDetailHeaderView: View {
    let productImages: [String]
    @Binding var currentPage: Int
    let infoCornerRadius: CGFloat
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBlue
                .frame(height: horizontalSizeClass == .compact ? 380 : 420)
                .clipShape(
                    RoundedCorner(radius: infoCornerRadius,
                                  corners: [.bottomLeft, .bottomRight])
                )
                .edgesIgnoringSafeArea(horizontalSizeClass == .compact ? .top : [])

            ImageCarouselViewFromUser(images: productImages,
                                      currentPage: $currentPage)
            .frame(width: UIScreen.main.bounds.width * (horizontalSizeClass == .compact ? 0.8 : 0.6),
                                  height: horizontalSizeClass == .compact ? 250 : 300)
               .padding(.bottom, 20)
        }
    }
}

struct ItemInfoPanelView: View {
    let item: DisplayItem
    let sampleReviews: [Review]
    let infoCornerRadius: CGFloat
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.name)
                .font(.system(size: horizontalSizeClass == .compact ? 24 : 28, weight: .bold))
                .foregroundColor(.appBlack)

            HStack(spacing: 12) {
                RatingViewFromUser(rating: 4.8, reviewCount: 69)
                AvailabilityViewFromUser(isAvailable: item.isAvailable ?? true)
                Spacer()
            }

            Text(item.rentalPrice)
                .font(horizontalSizeClass == .compact ? .title3 : .title2)
                .fontWeight(.semibold)
                .foregroundColor(.appBlack)

            ItemDescriptionSection(description: item.description)

            ItemReviewsSection(sampleReviews: sampleReviews)
            
            Spacer(minLength: horizontalSizeClass == .compact ? 120 : 150)
        }
        .padding()
        .background(Color.appWhite)
        .clipShape(
            RoundedCorner(
                radius: infoCornerRadius,
                corners: [.topLeft, .topRight]
            )
        )
    }
}

struct ItemReviewsSection: View {
    let sampleReviews: [Review]

    var body: some View {
        SectionViewFromUser(title: "Reviews", showAddButton: true) {
            if sampleReviews.isEmpty {
                Text("No reviews yet.")
                    .font(.body)
                    .foregroundColor(.appBlack.opacity(0.7))
            } else {
                ForEach(sampleReviews) { review in
                    ReviewCardViewFromUser(review: review)
                }
            }
        }
    }
}

struct ItemDescriptionSection: View {
    let description: String

    var body: some View {
        SectionViewFromUser(title: "Description") {
            Text(description.isEmpty ? "No description available." : description) // Display item's description
                .font(.body)
                .foregroundColor(.appBlack.opacity(0.7))
                .lineSpacing(5)
        }
    }
}

struct ImageCarouselViewFromUser: View {
    let images: [String]
    @Binding var currentPage: Int

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<images.count, id: \.self) { index in
                if UIImage(named: images[index]) != nil {
                    Image(images[index])
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .tag(index)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(Text("Image\nNot Found").multilineTextAlignment(.center).foregroundColor(.white))
                        .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct RatingViewFromUser: View {
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

struct AvailabilityViewFromUser: View {
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

struct SectionViewFromUser<Content: View>: View {
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

struct ReviewCardViewFromUser: View {
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

struct BorrowButtonModified: View {
    let item: DisplayItem

    var body: some View {
        NavigationLink(destination: RequestView(item: item)) {
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
    static var sampleItem = DisplayItem(id: "123", name: "Orange Trousers", imageName: "DummyProduct", rentalPrice: "Rp 20.000 /day", categoryId: 1, description: "These are some comfortable orange trousers, perfect for a sunny day out. Made from breathable cotton.", isAvailable: true, ownerUid: "owner123")

    static var previews: some View {
        NavigationView { ItemDetailView(item: sampleItem) }.preferredColorScheme(.light)
        NavigationView { ItemDetailView(item: sampleItem) }.preferredColorScheme(.dark)
    }
}
