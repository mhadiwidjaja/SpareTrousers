//
//  AccountSettingsModalView.swift
//  SpareTrousers
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct AccountSettingsModalView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String = ""
    @State private var address: String = ""
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                                    // Display Name Field
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Display Name")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("Enter display name", text: $displayName)
                                            .textContentType(.name)
                                    }
                                    .padding(.vertical, 4)

                                    // Address Field
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Your Address")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("Enter your address", text: $address)
                                            .textContentType(.fullStreetAddress)
                                    }
                                    .padding(.vertical, 4)
                                }

                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(isSaving)
                    
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                self.displayName = authViewModel.userSession?.displayName ?? ""
                self.address = authViewModel.userAddress ?? ""
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveChanges() {
        isSaving = true
        alertTitle = ""
        
        let newDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let newAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic validation
        if newDisplayName.isEmpty {
            alertTitle = "Validation Error"
            alertMessage = "Display name cannot be empty."
            showAlert = true
            isSaving = false
            return
        }

        let dispatchGroup = DispatchGroup()
        var displayNameError: String?
        var addressError: String?

        // Update Display Name
        if newDisplayName != (authViewModel.userSession?.displayName ?? "") {
            dispatchGroup.enter()
            authViewModel.updateUserDisplayName(newName: newDisplayName) { success, error in
                if !success {
                    displayNameError = error ?? "Failed to update display name."
                }
                dispatchGroup.leave()
            }
        }

        // Update Address
        if newAddress != (authViewModel.userAddress ?? "") {
            dispatchGroup.enter()
            authViewModel.updateUserAddress(newAddress: newAddress)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            isSaving = false
            var messages: [String] = []
            if let error = displayNameError { messages.append(error) }
            if let error = addressError { messages.append(error) }

            if messages.isEmpty {
                alertTitle = "Success"
                alertMessage = "Account settings updated successfully."
                showAlert = true
            } else {
                alertTitle = "Error"
                alertMessage = messages.joined(separator: "\n")
                showAlert = true
            }
        }
    }
}


struct AccountSettingsModalView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsModalView()
            .environmentObject(AuthViewModel())
    }
}
