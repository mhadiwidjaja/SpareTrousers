//
//  AccountSettingsModalView.swift
//  SpareTrousers
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct AccountSettingsModalView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Use your actual AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String = ""
    @State private var address: String = ""
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSaving = false // To show loading state

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                                    // Display Name Field with Label
                                    VStack(alignment: .leading, spacing: 2) { // Added VStack for label and field
                                        Text("Display Name")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("Enter display name", text: $displayName)
                                            .textContentType(.name)
                                    }
                                    .padding(.vertical, 4) // Add some vertical padding for the group

                                    // Address Field with Label
                                    VStack(alignment: .leading, spacing: 2) { // Added VStack for label and field
                                        Text("Your Address")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("Enter your address", text: $address)
                                            .textContentType(.fullStreetAddress)
                                    }
                                    .padding(.vertical, 4) // Add some vertical padding for the group
                                }

                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(isSaving) // Disable button while saving
                    
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
                // Potentially add a primary save button here too if preferred
            }
            .onAppear {
                // Initialize fields from AuthViewModel
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
        alertTitle = "" // Reset alert title
        
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
        
        // Assume address can be empty or add validation if needed
        // if newAddress.isEmpty {
        //     alertTitle = "Validation Error"
        //     alertMessage = "Address cannot be empty."
        //     showAlert = true
        //     isSaving = false
        //     return
        // }

        // Call AuthViewModel to update both display name and address
        // We'll assume AuthViewModel has a combined update function or separate ones.
        // For this example, let's assume separate update functions.

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
            dispatchGroup.enter() // Enter even if not strictly async, for pattern consistency
            // Assuming updateUserAddress is synchronous or we adapt it
            // For simplicity, let's assume it's synchronous as per original code.
            // If it were async, it would need a completion handler too.
            authViewModel.updateUserAddress(newAddress: newAddress) // Assuming this updates a @Published var or similar
            // If updateUserAddress were async with completion:
            // authViewModel.updateUserAddress(newAddress: newAddress) { success, error in
            //     if !success { addressError = error ?? "Failed to update address." }
            //     dispatchGroup.leave()
            // }
            dispatchGroup.leave() // Leave immediately if synchronous
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
                // Optionally dismiss after a short delay or let user dismiss alert
                // dismiss()
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
