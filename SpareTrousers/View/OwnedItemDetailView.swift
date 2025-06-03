//
//  OwnedItemDetailView.swift
//  SpareTrousers
//
//  Created by student on 03/06/25.
//

import SwiftUI

// Assuming Review struct is defined as in ItemDetailView or a shared location
// If not shared, you might need to define it here or ensure it's accessible.
// For this example, I'll assume 'Review' is accessible.
// struct Review: Identifiable { ... } // (If needed, or ensure it's imported from shared model)

struct OwnedItemDetailView: View { // Renamed from ItemDetailView
    let item: DisplayItem
    @State private var currentPage = 0

    var productImages: [String] {
        var images = [item.imageName]
        // Ensure your placeholder image names are correct if used
        images.append(contentsOf: ["SpareTrousers", "DummyProduct"])
        return images.filter { !$0.isEmpty }
    }

    // Sample reviews, same as in ItemDetailView
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
                    // These subviews (ItemDetailHeaderView, ItemInfoPanelView, etc.) are assumed to be
                    // the same as defined in/for ItemDetailView. If they were private to ItemDetailView,
                    // they would need to be copied here as well or made reusable.
                    // For this regeneration, I'm using the names as provided in your ItemDetailView.swift code.
                    ItemDetailHeaderView( // Assumes this struct is accessible
                        productImages: productImages,
                        currentPage: $currentPage,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -86)

                    ItemInfoPanelView( // Assumes this struct is accessible
                        item: item,
                        sampleReviews: sampleReviews,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -60)
                }
            }

            // MODIFIED BUTTON SECTION
            Button(action: {
                // Action for Edit button - none for now as requested
                print("Edit button tapped for item: \(item.name)")
            }) {
                Text("Edit")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.appBlue) // Changed background color for distinction, e.g., .appBlue or .gray
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, safeAreaBottomInset())
            // END OF MODIFIED BUTTON SECTION
        }
        .navigationTitle(item.name) // Keep navigation title
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        // This helper function remains the same
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 16
    }
}

// IMPORTANT: The subviews like ItemDetailHeaderView, ItemInfoPanelView, ImageCarouselViewFromUser, etc.
// are assumed to be accessible (e.g., defined in a shared place or also copied to this file if they were private to ItemDetailView.swift).
// If they are defined within ItemDetailView.swift and not as top-level structs, you'll need to
// extract them or duplicate them here. Your provided ItemDetailView.swift shows them as top-level structs.

// Preview for OwnedItemDetailView
struct OwnedItemDetailView_Previews: PreviewProvider { // Renamed preview struct
    static var sampleItem = DisplayItem(id: "123", name: "My Orange Trousers", imageName: "DummyProduct", rentalPrice: "Rp 20.000 /day", categoryId: 1, description: "These are my comfortable orange trousers.", isAvailable: true, ownerUid: "owner123")

    static var previews: some View {
        NavigationView { // Wrap in NavigationView for preview
            OwnedItemDetailView(item: sampleItem) // Preview the new view
        }.preferredColorScheme(.light)
    }
}
