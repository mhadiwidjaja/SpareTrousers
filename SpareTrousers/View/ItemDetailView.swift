//
//  ItemDetailView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//




import SwiftUI


//TODO: Maybe move this someplace else
// Assuming Review struct is defined as:
struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let reviewText: String
    let rating: Int
}



struct ItemDetailView: View {
    let item: DisplayItem
    @State private var currentPage = 0

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

            Color.appWhite
                .offset(y: 290) // Adjust if header height changes
                .edgesIgnoringSafeArea(.bottom)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ItemDetailHeaderView(
                        productImages: productImages,
                        currentPage: $currentPage,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -86)

                    ItemInfoPanelView(
                        item: item, // Pass the full item
                        sampleReviews: sampleReviews,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -60)
                }
            }

            BorrowButtonModified(item: item)
                .padding(.horizontal)
                .padding(.bottom, safeAreaBottomInset())
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

// MARK: - Subviews (Using user's provided versions, renamed for clarity in this merge)

struct ItemDetailHeaderView: View {
    let productImages: [String]
    @Binding var currentPage: Int
    let infoCornerRadius: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBlue
                .frame(height: 380) // Adjusted from your uploaded ItemDetailView
                .clipShape(
                    RoundedCorner(radius: infoCornerRadius,
                                  corners: [.bottomLeft, .bottomRight])
                )
                .edgesIgnoringSafeArea(.top)

            ImageCarouselViewFromUser(images: productImages,
                                      currentPage: $currentPage)
               .frame(width: UIScreen.main.bounds.width * 0.8,
                      height: 250)
               .padding(.bottom, 20)
        }
    }
}

struct ItemInfoPanelView: View {
    let item: DisplayItem // Now receives the full item
    let sampleReviews: [Review]
    let infoCornerRadius: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appBlack)

            HStack(spacing: 12) {
                RatingViewFromUser(rating: 4.8, reviewCount: 69)
                // Use item.isAvailable if you fetch it and pass it
                AvailabilityViewFromUser(isAvailable: item.isAvailable ?? true)
                Spacer()
            }

            Text(item.rentalPrice)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.appBlack)

            // Use item.description here
            ItemDescriptionSection(description: item.description)

            ItemReviewsSection(sampleReviews: sampleReviews)
            
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
                // Attempt to load image, provide fallback
                if UIImage(named: images[index]) != nil {
                    Image(images[index])
                        .resizable()
                        .scaledToFit() // Or .scaledToFill() depending on desired effect
                        .cornerRadius(12)
                        .tag(index)
                } else {
                    // Fallback view if image is not found
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(Text("Image\nNot Found").multilineTextAlignment(.center).foregroundColor(.white))
                        .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // Or .automatic
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
            Text("\(reviewCount) reviews") // Corrected from "69 reviews" to use reviewCount
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white) // Changed from secondarySystemBackground
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
        .background(Color.white) // Changed from secondarySystemBackground
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct SectionViewFromUser<Content: View>: View {
    let title: String
    var showAddButton: Bool = false // Not used in user's new version of SectionView, but kept for consistency
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline) // User's version uses .headline
                Spacer()
                if showAddButton {
                    Image(systemName: "plus") // User's version uses Image directly
                        .font(.headline)
                }
            }
            content
        }
    }
}

// ReviewCardView from user's code
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
        .background(Color.white) // Changed from secondarySystemBackground
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

// Borrow Button - Modified to be a NavigationLink
struct BorrowButtonModified: View {
    let item: DisplayItem // Pass the item to navigate with

    var body: some View {
        NavigationLink(destination: RequestView(item: item)) { // RequestView is from the other immersive
            Text("Borrow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 16) // User's version uses 16
                .frame(maxWidth: .infinity)
                .background(Color.orange) // Assuming .appOrange or direct .orange
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
