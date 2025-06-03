import SwiftUI

struct ForYouSection: View {
    let items: [DisplayItem]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("For You")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack)
                .padding(.leading, 5)

            if items.isEmpty {
                Text("No items match your search.")
                    .foregroundColor(
                        Color.appOffGray
                    )
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

    // ensure two lines of text get enough height
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
                    )  // Ensure left alignment of text
                    .frame(minHeight: twoLineHeight, alignment: .leading)

                Text(item.rentalPrice)
                    .font(.subheadline)
                    .foregroundColor(.appOffGray)
                    .multilineTextAlignment(
                        .leading
                    )  // Ensure left alignment of text
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .cornerRadius(10)
    }
}

