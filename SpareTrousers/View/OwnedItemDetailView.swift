// SpareTrousers/View/OwnedItemDetailView.swift

import SwiftUI

struct OwnedItemDetailView: View {
    let item: DisplayItem
    
    @State private var currentPage = 0
    @State private var showingEditItemView = false
    @EnvironmentObject var homeVM: HomeViewModel

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
                .offset(y: 290)
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
                        item: item,
                        sampleReviews: sampleReviews,
                        infoCornerRadius: infoCornerRadius
                    )
                    .offset(y: -60)
                }
            }

            Button(action: {
                showingEditItemView = true
            }) {
                Text("Edit")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.appBlue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, safeAreaBottomInset())
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditItemView) {
            EditItemsView(item: item)
                .environmentObject(homeVM)
        }
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 16
    }
}

// MARK: - Previews
struct OwnedItemDetailView_Previews: PreviewProvider {
    static var sampleItem = DisplayItem(
        id: "ownedPreviewID",
        name: "My Orange Trousers",
        imageName: "DummyProduct",
        rentalPrice: "Rp 20.000 /day",
        categoryId: 1,
        description: "These are my comfortable orange trousers, ready for editing.",
        isAvailable: true,
        ownerUid: "owner123"
    )
    
    static var mockHomeVM: HomeViewModel {
        let vm = HomeViewModel()
        vm.categories = [
            CategoryItem(id: 1, name: "Fashion", iconName: "tshirt.fill", color: .blue),
            CategoryItem(id: 2, name: "Cooking", iconName: "fork.knife.circle.fill", color: .orange)
        ]
        return vm
    }

    static var previews: some View {
        NavigationView {
            OwnedItemDetailView(item: sampleItem)
                .environmentObject(mockHomeVM)
        }.preferredColorScheme(.light)
    }
}
