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



// MARK: - Main View
struct ItemDetailView: View {
    // The item to display, passed from HomeView
    let item: DisplayItem

    @State private var currentPage = 0
    // State to control navigation to RequestView (optional if NavigationLink is direct)
    // @State private var isShowingRequestView = false // Can be removed if BorrowButton is a direct NavigationLink

    // Use item.imageName as the primary, then placeholders or other images from item
    var productImages: [String] {
        // In a real app, DisplayItem might have an array of image names.
        // For now, using the main image and then the placeholders from your example.
        var images = [item.imageName] // Primary image
        images.append(contentsOf: ["SpareTrousers", "DummyProduct"]) // Additional example images
        return images.filter { !$0.isEmpty } // Ensure no empty strings
    }

    // Sample reviews (could also come from 'item' if it had review details)
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
                .offset(y: 290) // 350 header height − 60 overlap
                .edgesIgnoringSafeArea(.bottom)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        Color.appBlue // Use your app's blue
                            .frame(height: 350)
                            .clipShape(
                                RoundedCorner(radius: infoCornerRadius,
                                              corners: [.bottomLeft, .bottomRight])
                            )
                            .edgesIgnoringSafeArea(.top)

                        // ImageCarouselView using the productImages derived from 'item'
                        ImageCarouselViewFromUser(images: productImages,
                                          currentPage: $currentPage)
                           .frame(width: UIScreen.main.bounds.width * 0.8,
                                  height: 250)
                           .padding(.bottom, 20)
                    }
                    .offset(y: -86) // This offset might need adjustment if header height changes

                    VStack(alignment: .leading, spacing: 16) {
                        Text(item.name) // Use item's name
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appBlack)

                        HStack(spacing: 12) {
                            RatingViewFromUser(rating: 4.8, reviewCount: 69) // Placeholder rating
                            AvailabilityViewFromUser(isAvailable: true)      // Placeholder availability
                            Spacer()
                        }

                        Text(item.rentalPrice) // Use item's price
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.appBlack)

                        SectionViewFromUser(title: "Description") {
                            // Placeholder description. Ideally, this would come from 'item.description'
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas. In vitae ipsum ac dui facilisis tristique ac quis ligula. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque suscipit et turpis vel placerat. Aliquam non lectus efficitur, sagittis quam id, pulvinar mi.")
                                .font(.body)
                                .foregroundColor(.appBlack.opacity(0.7))
                                .lineSpacing(5)
                        }

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
                        Spacer(minLength: 120) // Space for the borrow button
                    }
                    .padding()
                    .background(Color.appWhite)
                    .clipShape(
                        RoundedCorner(
                            radius: infoCornerRadius,
                            corners: [.topLeft, .topRight]
                        )
                    )
                    .offset(y: -60) // This offset pulls the white panel up
                }
            }
            // Navigation is handled by the NavigationView in HomeView
            // .navigationBarTitleDisplayMode(.inline) // Already set if pushed by NavLink
            // .navigationTitle(item.name) // Already set if pushed by NavLink

            // Borrow Button - Modified to navigate
            // It's placed in ZStack to overlay on ScrollView content
            BorrowButtonModified(item: item) // Pass the item to BorrowButton
                .padding(.horizontal)
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 16) // Adjust padding if home indicator is present
        }
        // ItemDetailView itself should not ignore safe area at top if it has a nav bar from parent
        // .edgesIgnoringSafeArea(.top) // Re-evaluate this; if part of NavStack, top is usually handled
        // The ZStack with Color.appBlue already handles .edgesIgnoringSafeArea(.top) for the blue header part
        .navigationTitle(item.name) // Set title for the navigation bar
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews (Using user's provided versions, renamed for clarity in this merge)



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


// MARK: - Preview
struct ItemDetailView_Previews: PreviewProvider {
    // Sample item for preview. Ensure "DummyProduct" exists in your Assets.
    static var sampleItem = DisplayItem(name: "Orange and Blue Trousers", imageName: "DummyProduct", rentalPrice: "Rp 20.000 /day")

    static var previews: some View {
        // Wrap in NavigationView for previewing navigation behavior
        NavigationView {
            ItemDetailView(item: sampleItem)
        }
        .preferredColorScheme(.light) // User's preview was light only, added dark for completeness
        
        NavigationView {
            ItemDetailView(item: sampleItem)
        }
        .preferredColorScheme(.dark)
    }
}
