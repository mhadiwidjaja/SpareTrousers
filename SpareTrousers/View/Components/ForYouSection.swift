import SwiftUI

struct ForYouSection: View {
    let items: [DisplayItem]
    
    // Access the horizontal size class from the environment
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Define the columns based on the horizontal size class
    private var columns: [GridItem] {
        // If the horizontal size class is regular (e.g., iPad in landscape, some larger iPhones in landscape), use 3 columns.
        // Otherwise (compact, e.g., iPhone in portrait), use 2 columns.
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let numberOfColumns = isPad ? 5 : 2
        
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: numberOfColumns)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("For You")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack)
                .padding(.leading, 5)

            if items.isEmpty {
                Text("No items match your search or selection.")
                    .foregroundColor(Color.appOffGray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(
                            destination: ItemDetailView(item: item)
                        ) {
                            ItemCardView(item: item)
                        }
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
