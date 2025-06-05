//
//  SeedingService.swift
//  SpareTrousers
//
//  Created by student on 30/05/25.
//

import Foundation 
import FirebaseDatabase
import SwiftUI

class SeedingService {

    private let dbRef: DatabaseReference
    private let localCategories: [CategoryItem]
    
    init() {
        self.dbRef = Database.database().reference()
        self.localCategories = [
                    CategoryItem(id: 1, name: "Fashion", iconName: "tshirt.fill", color: Color(hex:"009CFD").opacity(0.7)),
                    CategoryItem(id: 2, name: "Cooking", iconName: "fork.knife.circle.fill", color: Color(hex:"FDA200").opacity(0.7)),
                    CategoryItem(id: 3, name: "Tools", iconName: "wrench.and.screwdriver.fill", color: Color(hex:"4F767E").opacity(0.7)),
                    CategoryItem(id: 4, name: "Toys", iconName: "gamecontroller.fill", color: Color.yellow.opacity(0.8)),
                    CategoryItem(id: 5, name: "Outdoor", iconName: "leaf.fill", color: Color.green.opacity(0.8)),
                    CategoryItem(id: 6, name: "Electronics", iconName: "tv.and.hifispeaker.fill", color: Color.purple.opacity(0.7))
                ]
    }

    func seedDummyItemsToFirebase() {
        guard !localCategories.isEmpty else {
                    print("SEEDING ERROR: Internal categories not initialized."); return
                }
        
        let fashionCategory = localCategories.first(where: { $0.id == 1 })
                let toolsCategory = localCategories.first(where: { $0.id == 3 })
                let cookingCategory = localCategories.first(where: { $0.id == 2 })
                let outdoorCategory = localCategories.first(where: { $0.id == 5 })
                let toysCategory = localCategories.first(where: { $0.id == 4 })
                let electronicsCategory = localCategories.first(where: { $0.id == 6 })

        let ownerUid1 = "KUIsLpNJjkeVkw5lT66RaCd7Vzd2"
        let ownerUid2 = "2Vy8OiKlaUeXcR4poqidlTCDF4a2"

        let itemsToSeed: [(name: String, category: CategoryItem?, price: String, owner: String, description: String)] = [
            ("Stylish Blue Jeans", fashionCategory, "Rp 30.000 /day", ownerUid1, "Comfortable and durable blue jeans."),
            ("Vintage Leather Jacket", fashionCategory, "Rp 50.000 /day", ownerUid2, "A classic leather jacket with a retro vibe."),
            ("Power Drill Kit", toolsCategory, "Rp 40.000 /day", ownerUid1, "Complete power drill set for all your DIY needs."),
            ("Chef's Knife Set", cookingCategory, "Rp 25.000 /day", ownerUid2, "High-quality stainless steel chef's knives."),
            ("Non-stick Frying Pan", cookingCategory, "Rp 15.000 /day", ownerUid1, "Perfect for everyday cooking, easy to clean."),
            ("Designer Handbag", fashionCategory, "Rp 75.000 /day", ownerUid2, "Elegant designer handbag for special occasions."),
            ("Hammer and Nail Set", toolsCategory, "Rp 10.000 /day", ownerUid1, "Basic hammer and assorted nails."),
            ("Summer Dress", fashionCategory, "Rp 20.000 /day", ownerUid1, "Light and airy summer dress."),
            ("Hiking Boots", outdoorCategory, "Rp 60.000 /day", ownerUid2, "Sturdy hiking boots for tough trails."),
            ("Board Game Collection", toysCategory, "Rp 35.000 /day", ownerUid1, "Fun board games for the whole family."),
            ("Bluetooth Speaker", electronicsCategory, "Rp 25.000 /day", ownerUid2, "Portable speaker with great sound."),
            ("Yoga Mat", outdoorCategory, "Rp 10.000 /day", ownerUid1, "Eco-friendly yoga mat."),
            ("Digital Camera", electronicsCategory, "Rp 100.000 /day", ownerUid2, "High-resolution digital camera."),
            ("Tent for Camping", outdoorCategory, "Rp 80.000 /day", ownerUid1, "Spacious tent for 2-3 people."),
            ("Electric Kettle", cookingCategory, "Rp 12.000 /day", ownerUid2, "Quickly boils water for tea or coffee."),
            ("RC Car", toysCategory, "Rp 40.000 /day", ownerUid1, "Fast remote-controlled car."),
            ("Winter Scarf", fashionCategory, "Rp 18.000 /day", ownerUid2, "Warm and stylish winter scarf."),
            ("Screwdriver Set", toolsCategory, "Rp 15.000 /day", ownerUid1, "Various screwdrivers for different tasks."),
            ("Portable Charger", electronicsCategory, "Rp 20.000 /day", ownerUid2, "Keep your devices charged on the go."),
            ("Baking Mixer", cookingCategory, "Rp 30.000 /day", ownerUid1, "Powerful mixer for baking enthusiasts."),
            ("Kids Building Blocks", toysCategory, "Rp 22.000 /day", ownerUid2, "Colorful building blocks for creative play.")
        ]

        let itemsRef = dbRef.child("items")

        for itemTuple in itemsToSeed {
            guard let category = itemTuple.category else {
                print("SEEDING WARNING: Category not found for item '\(itemTuple.name)'. Check if category exists in provided list. Skipping.")
                continue
            }
            
            guard let newItemFirebaseId = itemsRef.childByAutoId().key else {
                print("SEEDING ERROR: Could not generate item ID for \(itemTuple.name)")
                continue
            }
            
            let itemData: [String: Any] = [
                "name": itemTuple.name,
                "description": itemTuple.description,
                "imageName": "DummyProduct",
                "rentalPrice": itemTuple.price,
                "categoryId": category.id,
                "ownerUid": itemTuple.owner,
                "isAvailable": Bool.random(),
                "dateListed": ISO8601DateFormatter().string(from: Date(timeIntervalSinceNow: Double.random(in: -1000000...0)))
            ]
            
            itemsRef.child(newItemFirebaseId).setValue(itemData) { error, ref in
                if let error = error {
                    print("SEEDING ERROR for item '\(itemTuple.name)': \(error.localizedDescription)")
                } else {
                    print("SEEDING SUCCESS: Item '\(itemTuple.name)' added with ID: \(newItemFirebaseId)")
                }
            }
        }
        print("--- Finished attempting to seed dummy items via SeedingService ---")
    }
}
