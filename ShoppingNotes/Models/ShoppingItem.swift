//
//  ShoppingItem.swift
//  ShoppingNotes
//
//  Created by Claude on 2024.
//

import Foundation

struct ShoppingItem: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var recognizedPrice: Double?
    var isChecked: Bool = false

    var displayPrice: String {
        if let price = recognizedPrice {
            return String(format: "$%.2f", price)
        }
        return ""
    }
}
