import SwiftUI

struct CategoriesSection: View {
    let categories: [CategoryItem]
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.custom("MarkerFelt-Wide", size: 24))
                .foregroundColor(.appBlack)
                .padding(.leading, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories) { cat in
                        CategoryView(category: cat)
                            .onTapGesture {
                                homeViewModel.selectCategory(cat)
                            }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct CategoryView: View {
    let category: CategoryItem
    @EnvironmentObject var homeViewModel: HomeViewModel
    var isSelected: Bool { homeViewModel.selectedCategoryId == category.id }
    
    var body: some View {
        VStack {
            ZStack {
                category.color
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelected ? Color.appBlack : Color.clear,
                                lineWidth: 2
                            )
                    )
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.appWhite)
            }
            Text(category.name)
                .font(.caption)
                .foregroundColor(.appBlack)
        }
    }
}
