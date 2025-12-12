//
//  ShoppingViewModel.swift
//  ShoppingNotes
//
//  Created by Claude on 2024.
//

import Foundation
import SwiftUI

class ShoppingViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var noteTitle: String = "Shopping List"

    // MARK: - Computed Properties

    var totalItems: Int {
        items.count
    }

    var checkedItems: Int {
        items.filter { $0.isChecked }.count
    }

    var totalPrice: Double {
        items.compactMap { $0.recognizedPrice }.reduce(0, +)
    }

    var formattedTotalPrice: String {
        String(format: "$%.2f", totalPrice)
    }

    // MARK: - Methods

    func addItem(from text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let price = recognizePrice(from: text)
        let item = ShoppingItem(text: text, recognizedPrice: price)
        items.append(item)
    }

    func updateItem(at index: Int, with text: String) {
        guard index < items.count else { return }
        items[index].text = text
        items[index].recognizedPrice = recognizePrice(from: text)
    }

    func toggleCheck(for item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
        }
    }

    func deleteItem(_ item: ShoppingItem) {
        items.removeAll { $0.id == item.id }
    }

    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func updatePrice(for item: ShoppingItem, with text: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].recognizedPrice = recognizePrice(from: text)
        }
    }

    // MARK: - AI Price Recognition

    /// Recognizes price from text using pattern matching and NLP-like heuristics
    /// Supports formats like: $5.99, 5.99, $5, 5 dollars, etc.
    func recognizePrice(from text: String) -> Double? {
        let lowercased = text.lowercased()

        // Pattern 1: $XX.XX or $XX format
        let dollarPattern = #"\$\s*(\d+(?:\.\d{1,2})?)"#
        if let match = text.range(of: dollarPattern, options: .regularExpression) {
            let matchedString = String(text[match])
            let numberString = matchedString.replacingOccurrences(of: "$", with: "")
                .trimmingCharacters(in: .whitespaces)
            if let price = Double(numberString) {
                return price
            }
        }

        // Pattern 2: XX.XX or XX followed by "dollars" or "dollar"
        let dollarsWordPattern = #"(\d+(?:\.\d{1,2})?)\s*(?:dollars?|bucks?)"#
        if let match = lowercased.range(of: dollarsWordPattern, options: .regularExpression) {
            let matchedString = String(lowercased[match])
            let numberPattern = #"\d+(?:\.\d{1,2})?"#
            if let numberMatch = matchedString.range(of: numberPattern, options: .regularExpression) {
                let numberString = String(matchedString[numberMatch])
                if let price = Double(numberString) {
                    return price
                }
            }
        }

        // Pattern 3: "costs XX.XX" or "price XX.XX" or "@ XX.XX"
        let costPattern = #"(?:costs?|price[d]?|@|at)\s*\$?\s*(\d+(?:\.\d{1,2})?)"#
        if let match = lowercased.range(of: costPattern, options: .regularExpression) {
            let matchedString = String(lowercased[match])
            let numberPattern = #"\d+(?:\.\d{1,2})?"#
            if let numberMatch = matchedString.range(of: numberPattern, options: .regularExpression) {
                let numberString = String(matchedString[numberMatch])
                if let price = Double(numberString) {
                    return price
                }
            }
        }

        // Pattern 4: XX.XX at end of string (likely a price)
        let endPricePattern = #"(\d+\.\d{2})\s*$"#
        if let match = text.range(of: endPricePattern, options: .regularExpression) {
            let numberString = String(text[match]).trimmingCharacters(in: .whitespaces)
            if let price = Double(numberString) {
                return price
            }
        }

        // Pattern 5: Quantity x Price (e.g., "2 x $3.50" or "2x3.50")
        let multiplyPattern = #"(\d+)\s*[xX×]\s*\$?\s*(\d+(?:\.\d{1,2})?)"#
        if let match = text.range(of: multiplyPattern, options: .regularExpression) {
            let matchedString = String(text[match])
            let numbers = matchedString.components(separatedBy: CharacterSet(charactersIn: "xX×"))
            if numbers.count == 2 {
                let qty = Double(numbers[0].trimmingCharacters(in: .whitespaces)) ?? 1
                let priceStr = numbers[1].replacingOccurrences(of: "$", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if let unitPrice = Double(priceStr) {
                    return qty * unitPrice
                }
            }
        }

        // Pattern 6: "for $XX" or "for XX dollars"
        let forPattern = #"for\s+\$?\s*(\d+(?:\.\d{1,2})?)"#
        if let match = lowercased.range(of: forPattern, options: .regularExpression) {
            let matchedString = String(lowercased[match])
            let numberPattern = #"\d+(?:\.\d{1,2})?"#
            if let numberMatch = matchedString.range(of: numberPattern, options: .regularExpression) {
                let numberString = String(matchedString[numberMatch])
                if let price = Double(numberString) {
                    return price
                }
            }
        }

        return nil
    }
}
