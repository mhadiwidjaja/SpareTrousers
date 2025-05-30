//
//  AddItemsView.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import SwiftUI
import FirebaseAuth

struct AddItemsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedCategory: CategoryItem? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("Rental Price", text: $price)
                        .keyboardType(.numberPad)

                    Picker("Category", selection: $selectedCategory) {
                        Text("Select...").tag(CategoryItem?.none)
                        ForEach(homeVM.categories, id: \.self) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                Text(category.name)
                            }
                            .tag(Optional(category))
                        }
                    }
                }

                Section {
                    Button("Save") {
                        guard
                            let uid = Auth.auth().currentUser?.uid,
                            let category = selectedCategory,
                            !name.trimmingCharacters(in: .whitespaces).isEmpty,
                            !price.trimmingCharacters(in: .whitespaces).isEmpty
                        else {
                            return
                        }

                        homeVM.addItemToFirebase(
                            name: name,
                            localCategory: category,
                            price: price,
                            ownerUid: uid
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || price.isEmpty || selectedCategory == nil)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarItems(leading:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct AddItemsView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy HomeViewModel with categories for preview
        AddItemsView()
            .environmentObject({
                let vm = HomeViewModel()
                vm.categories = [
                    CategoryItem(id: 1, name: "Fashion",    iconName: "tshirt.fill",                color: .blue),
                    CategoryItem(id: 2, name: "Cooking",    iconName: "fork.knife.circle.fill",     color: .orange),
                    CategoryItem(id: 3, name: "Tools",      iconName: "wrench.and.screwdriver.fill",color: .gray),
                    CategoryItem(id: 4, name: "Toys",       iconName: "gamecontroller.fill",        color: .yellow),
                    CategoryItem(id: 5, name: "Outdoor",    iconName: "leaf.fill",                  color: .green),
                    CategoryItem(id: 6, name: "Electronics",iconName: "tv.and.hifispeaker.fill",     color: .purple)
                ]
                return vm
            }())
    }
}
