//
//  EditItemsView.swift
//  SpareTrousers
//
//  Created by student on 03/06/25.
//

import SwiftUI
import FirebaseAuth

struct EditItemsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @Environment(\.presentationMode) private var presentationMode

    let itemToEdit: DisplayItem

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedCategory: CategoryItem? = nil
    @State private var description: String = ""
    @State private var isAvailable: Bool = true

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var updateSuccessful = false

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }

    init(item: DisplayItem) {
        self.itemToEdit = item
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description)
        _isAvailable = State(initialValue: item.isAvailable ?? true)

        let numericPriceString = item.rentalPrice
            .replacingOccurrences(of: "Rp ", with: "")
            .replacingOccurrences(of: " /day", with: "")
            .replacingOccurrences(of: ".", with: "")
        _price = State(initialValue: numericPriceString)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("Enter Price (e.g., 50000)", text: $price)
                        .keyboardType(.decimalPad)
                        .onChange(of: price) { oldValue, newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
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
                    
                    Toggle("Item is Available", isOn: $isAvailable)
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3)))
                }

                Section {
                    Button("Update") {
                        updateItem()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        selectedCategory == nil ||
                        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                self.name = itemToEdit.name
                self.description = itemToEdit.description
                self.isAvailable = itemToEdit.isAvailable ?? true
                
                let numericPriceString = itemToEdit.rentalPrice
                    .replacingOccurrences(of: "Rp ", with: "")
                    .replacingOccurrences(of: " /day", with: "")
                    .replacingOccurrences(of: ".", with: "")
                self.price = numericPriceString

                if let category = homeVM.categories.first(where: { $0.id == itemToEdit.categoryId }) {
                    self.selectedCategory = category
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(updateSuccessful ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if updateSuccessful {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }

    private func updateItem() {
        guard let category = selectedCategory else {
            alertMessage = "Please select a category."
            updateSuccessful = false
            showAlert = true
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty || trimmedPrice.isEmpty || trimmedDescription.isEmpty {
            alertMessage = "All fields must be filled."
            updateSuccessful = false
            showAlert = true
            return
        }

        guard let priceValue = Int(trimmedPrice) else {
            alertMessage = "Invalid price entered. Please enter a whole number."
            updateSuccessful = false
            showAlert = true
            return
        }
        let formattedPriceString = "Rp \(priceValue) /day"

        let updatedItemData: [String: Any] = [
            "name": trimmedName,
            "description": trimmedDescription,
            "categoryId": category.id,
            "rentalPrice": formattedPriceString,
            "imageName": itemToEdit.imageName,
            "ownerUid": itemToEdit.ownerUid ?? (Auth.auth().currentUser?.uid ?? ""),
            "isAvailable": isAvailable,
        ]
        
        homeVM.updateItemInFirebase(itemId: itemToEdit.id, itemData: updatedItemData) { success, error in
            if success {
                self.alertMessage = "Item updated successfully!"
                self.updateSuccessful = true
            } else {
                self.alertMessage = "Failed to update item: \(error ?? "Unknown error")"
                self.updateSuccessful = false
            }
            self.showAlert = true
        }
    }
}

struct EditItemsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = DisplayItem(
            id: "previewItemID",
            name: "Old Trousers",
            imageName: "DummyProduct",
            rentalPrice: "Rp 15.000 /day",
            categoryId: 1,
            description: "These are old but comfy trousers.",
            isAvailable: true,
            ownerUid: "previewOwnerUID"
        )

        let mockHomeVM = HomeViewModel()
        mockHomeVM.categories = [
            CategoryItem(id: 1, name: "Fashion", iconName: "tshirt.fill", color: .blue),
            CategoryItem(id: 2, name: "Electronics", iconName: "tv.and.hifispeaker.fill", color: .purple)
        ]

        return EditItemsView(item: sampleItem)
            .environmentObject(mockHomeVM)
    }
}
