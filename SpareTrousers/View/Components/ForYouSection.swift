import SwiftUI

struct ForYouSection: View {
    let items: [DisplayItem]
    
    // Access the horizontal size class from the environment
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Define the columns based on the horizontal size class
    private var columns: [GridItem] {
        // If the horizontal size class is regular (e.g., iPad in landscape, some larger iPhones in landscape), use 3 columns.
        // Otherwise (compact, e.g., iPhone in portrait), use 2 columns.
        // You can also check for specific user interface idioms like .pad
        // if UIDevice.current.userInterfaceIdiom == .pad { ... }
        // but horizontalSizeClass is generally preferred for adaptive UI.
        
        // For simplicity and directness based on your request:
        // Use 3 columns if it's not compact (implying it's regular, common for iPad)
        // Or explicitly check for iPad idiom if that's the sole criteria
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let numberOfColumns = isPad ? 3 : 2
        
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: numberOfColumns)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("For You")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack) // Make sure .appBlack is defined
                .padding(.leading, 5)

            if items.isEmpty {
                Text("No items match your search or selection.") // Updated empty state message
                    .foregroundColor(Color.appOffGray) // Make sure .appOffGray is defined
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
//                        NavigationLink(
//                            // Ensure ItemDetailView is correctly defined and accepts 'item'
//                            destination: ItemDetailView(item: item)
//                        ) {
                 //       NavigationLink(destination: Text("Isolated: \(item.name)")) {
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            ItemCardView(item: item)
                        }
                        // Apply a plain button style if you want to remove default NavigationLink styling from the card
                         .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct ItemCardView: View {
    let item: DisplayItem

    private var twoLineHeight: CGFloat {
        let f = UIFont.preferredFont(forTextStyle: .headline)
        return f.lineHeight * 2 + f.leading
    }

    var body: some View {
        VStack(alignment: .leading) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 177, height: 177)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.appBlack)
                    .lineLimit(2)
                    .multilineTextAlignment(
                        .leading
                    )
                    .frame(minHeight: twoLineHeight, alignment: .leading)

                Text(item.rentalPrice)
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)
                    .multilineTextAlignment(
                        .leading
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .cornerRadius(10)
    }
}

//struct ForYouSection_Previews: PreviewProvider {
//    static let sampleItems: [DisplayItem] = [
//        // Populate with sample DisplayItem data conforming to your actual model
//        // Example:
//         DisplayItem(id: "1", name: "Cool Blue Jacket", imageName: "DummyProduct", rentalPrice: "Rp 30.000 /day", categoryId: 1, description: "A cool blue jacket."),
//         DisplayItem(id: "2", name: "Vintage Camera Setup", imageName: "DummyProduct", rentalPrice: "Rp 50.000 /day", categoryId: 6, description: "Old but gold camera."),
//         DisplayItem(id: "3", name: "Another Great Item For You", imageName: "DummyProduct", rentalPrice: "Rp 25.000 /day", categoryId: 1, description: "Description 3"),
//         DisplayItem(id: "4", name: "Item Four", imageName: "DummyProduct", rentalPrice: "Rp 60.000 /day", categoryId: 3, description: "Description 4"),
//         DisplayItem(id: "5", name: "Fifth Item Showcase", imageName: "DummyProduct", rentalPrice: "Rp 40.000 /day", categoryId: 4, description: "Description 5"),
//         DisplayItem(id: "6", name: "The Sixth Item", imageName: "DummyProduct", rentalPrice: "Rp 90.000 /day", categoryId: 5, description: "Description 6")
//    ]
//
//    static var previews: some View {
//        // You'll need placeholder DisplayItem, AuthViewModel, HomeViewModel, etc. for previews to fully work.
//        // For now, let's assume sampleItems can be populated.
//        // If sampleItems is empty, it will show the "No items" message.
//        
//        // For a more complete preview, ensure DisplayItem matches your actual model.
//        // And that ItemDetailView can be initialized with it.
//        let previewItems = [
//            DisplayItem(id: "prev1", name: "Preview Item 1 (Long Name to Test Wrapping)", imageName: "DummyProduct", rentalPrice: "Rp 100k", categoryId: 1, description: "Desc 1"),
//            DisplayItem(id: "prev2", name: "Preview Item 2", imageName: "DummyProduct", rentalPrice: "Rp 200k", categoryId: 2, description: "Desc 2"),
//            DisplayItem(id: "prev3", name: "Preview Item 3", imageName: "DummyProduct", rentalPrice: "Rp 300k", categoryId: 1, description: "Desc 3"),
//            DisplayItem(id: "prev4", name: "Preview Item 4", imageName: "DummyProduct", rentalPrice: "Rp 400k", categoryId: 3, description: "Desc 4"),
//            DisplayItem(id: "prev5", name: "Preview Item 5", imageName: "DummyProduct", rentalPrice: "Rp 500k", categoryId: 2, description: "Desc 5"),
//        ]
//
//
//        Group {
//            NavigationView { // Wrap in NavigationView for NavigationLink
//                ScrollView {
//                    ForYouSection(items: previewItems)
//                        .padding()
//                }
//            }
//            .previewDevice("iPhone 14 Pro")
//            .previewDisplayName("For You - iPhone")
//
//            NavigationView {
//                ScrollView {
//                    ForYouSection(items: previewItems)
//                        .padding()
//                }
//            }
//            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
//            .previewDisplayName("For You - iPad")
//        }
//    }
//}
