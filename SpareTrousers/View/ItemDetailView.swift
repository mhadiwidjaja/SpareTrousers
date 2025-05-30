//
//  ItemDetailView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//


import SwiftUI

// MARK: - Main View
struct ItemDetailView: View {
    // State for the current page in the image carousel
    @State private var currentPage = 0
    // Placeholder for image names. Replace with your actual image assets.
    let productImages = ["placeholder_image_1", "placeholder_image_2", "placeholder_image_3"]
    // Placeholder for review data
    let sampleReviews = [
        Review(reviewerName: "Jimbo", reviewText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas.", rating: 4)
    ]

    var body: some View {
        NavigationView { // Added NavigationView for potential navigation bar and back button functionality
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Image Carousel
                    ImageCarouselView(images: productImages, currentPage: $currentPage)
                        .frame(height: 300) // Adjust height as needed

                    // MARK: - Product Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Orange and Blue Trousers")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(UIColor.label)) // Adapts to light/dark mode

                        HStack(spacing: 16) {
                            RatingView(rating: 4.8, reviewCount: 69)
                            AvailabilityView(isAvailable: true)
                            Spacer()
                        }

                        Text("Rp 20.000 /day")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black) // Using orange for price as in the image

                    }
                    .padding()

                    // MARK: - Description Section
                    SectionView(title: "Description") {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam id mauris interdum egestas. In vitae ipsum ac dui facilisis tristique ac quis ligula. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque suscipit et turpis vel placerat. Aliquam non lectus efficitur, sagittis quam id, pulvinar mi.")
                            .font(.body)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .lineSpacing(5)
                    }
                    .padding(.horizontal)

                    // MARK: - Reviews Section
                    SectionView(title: "Reviews", showAddButton: true) {
                        if sampleReviews.isEmpty {
                            Text("No reviews yet.")
                                .font(.body)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        } else {
                            ForEach(sampleReviews) { review in
                                ReviewCardView(review: review)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top) // Add some top padding to separate from description

                    Spacer(minLength: 20) // Add space before the button
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar as we have a custom back button
            .overlay( // Overlay for the custom back button
                CustomBackButton(),
                alignment: .topLeading
            )
            .safeAreaInset(edge: .bottom) { // Ensure button is above safe area
                 BorrowButton()
                    .padding()
                    .background(Color(UIColor.systemBackground)) // Match background
            }
            .edgesIgnoringSafeArea(.top) // Allow image carousel to go to the top edge
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recommended for fixing some layout issues
    }
}

// MARK: - Subviews

// Custom Back Button
struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.white) // White color for better visibility on image
                .padding()
                .background(Color.black.opacity(0.5)) // Semi-transparent background
                .clipShape(Circle())
        }
        .padding(.leading)
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) // Adjust for status bar
    }
}


// Image Carousel
struct ImageCarouselView: View {
    let images: [String]
    @Binding var currentPage: Int

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                ForEach(0..<images.count, id: \.self) { index in
                    // In a real app, you'd load images from assets or URLs
                    // Using SF Symbols or colored rectangles as placeholders
                    ZStack {
                        if UIImage(named: images[index]) != nil {
                             Image(images[index])
                                .resizable()
                                .scaledToFill() // Changed to scaledToFill to mimic the example
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped() // Clip to bounds
                        } else {
                            // Fallback placeholder if image is not found
                            Rectangle()
                                .fill(index % 2 == 0 ? Color.blue.opacity(0.7) : Color.blue.opacity(0.7))
                                .overlay(Text("Image \(index + 1)").foregroundColor(.white))
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// Rating View
struct RatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
                .fontWeight(.semibold)
            Text("(\(reviewCount) reviews)")
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
}

// Availability View
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
}

// Generic Section View
struct SectionView<Content: View>: View {
    let title: String
    var showAddButton: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                if showAddButton {
                    Button(action: {
                        // Action for adding a review or other item
                        print("\(title) add button tapped")
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            content
        }
    }
}

// Review Data Model
struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let reviewText: String
    let rating: Int // Rating out of 5
}

// Review Card View
struct ReviewCardView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("From \(review.reviewerName)")
                    .font(.headline)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            Text(review.reviewText)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(3) // Limit lines to keep it concise
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// Borrow Button
struct BorrowButton: View {
    var body: some View {
        Button(action: {
            // Action for borrowing the item
            print("Borrow button tapped")
        }) {
            Text("Borrow")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(Color.orange) // Using orange as in the image
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
        }
    }
}


// MARK: - Preview
struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // You'll need to add some placeholder images to your Assets.xcassets
        // with names "placeholder_image_1", "placeholder_image_2", "placeholder_image_3"
        // for the preview to work correctly with images.
        // If you don't have these, the carousel will show colored rectangles.
        ItemDetailView()
            .preferredColorScheme(.light) // Preview in light mode

        ItemDetailView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
