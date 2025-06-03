//
//  AddItemsView.swift
//  SpareTrousers
//

import SwiftUI
import FirebaseAuth

struct AddItemsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedCategory: CategoryItem? = nil
    @State private var description: String = ""
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    TextField("Enter Price (e.g., 50000)", text: $price)
                        .keyboardType(.decimalPad)
                        .onChange(of: price) {
                            oldValue,
                            newValue in
                            let filtered = newValue.filter {
                                "0123456789.,".contains($0)
                            }
                            if filtered != newValue {
                                self.price = filtered
                            }
                        }

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

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3)))
                }

                Section {
                    Button("Save") {
                        guard
                            let uid = Auth.auth().currentUser?.uid,
                            let category = selectedCategory,
                            !name.trimmingCharacters(in: .whitespaces).isEmpty,
                            !price.trimmingCharacters(in: .whitespaces).isEmpty,
                            !description
                                .trimmingCharacters(in: .whitespaces).isEmpty
                        else {
                            return
                        }
                        
                        let sanitizedPriceInput = price.replacingOccurrences(
                            of: ",",
                            with: "."
                        )
                        guard let priceValue = Double(sanitizedPriceInput) else {
                            print("Error: Invalid price entered.")
                            return
                        }
                        let formattedPriceString = "Rp. \(Int(priceValue)) /day"

                        homeVM.addItemToFirebase(
                            name: name,
                            description: description,
                            localCategory: category,
                            price: formattedPriceString,
                            ownerUid: uid
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(
                        name.isEmpty
                        || price.isEmpty
                        || selectedCategory == nil
                        || description.isEmpty
                    )
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
        AddItemsView()
            .environmentObject(
                {
                    let vm = HomeViewModel()
                    vm.categories = [
                        CategoryItem(
                            id: 1,
                            name: "Fashion",
                            iconName: "tshirt.fill",
                            color: .blue
                        ),
                        CategoryItem(
                            id: 2,
                            name: "Cooking",
                            iconName: "fork.knife.circle.fill",
                            color: .orange
                        ),
                        CategoryItem(
                            id: 3,
                            name: "Tools",
                            iconName: "wrench.and.screwdriver.fill",
                            color: .gray
                        ),
                        CategoryItem(
                            id: 4,
                            name: "Toys",
                            iconName: "gamecontroller.fill",
                            color: .yellow
                        ),
                        CategoryItem(
                            id: 5,
                            name: "Outdoor",
                            iconName: "leaf.fill",
                            color: .green
                        ),
                        CategoryItem(
                            id: 6,
                            name: "Electronics",
                            iconName: "tv.and.hifispeaker.fill",
                            color: .purple
                        )
                    ]
                    return vm
                }())
    }
}
