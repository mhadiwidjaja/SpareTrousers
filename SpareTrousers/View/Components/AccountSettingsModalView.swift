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

    @State private var address: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Address")) {
                    TextField("Enter your address", text: $address)
                        .textContentType(.fullStreetAddress)
                }

                Button("Save Address") {
                    if address
                        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        alertMessage = "Address cannot be empty."
                        showAlert = true
                    } else {
                        authViewModel.updateUserAddress(newAddress: address)
                        dismiss()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Validation Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
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
                self.address = authViewModel.userAddress ?? ""
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
