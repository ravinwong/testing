//
//  TotalsSummaryView.swift
//  ShoppingNotes
//
//  Created by Claude on 2024.
//

import SwiftUI

struct TotalsSummaryView: View {
    let itemCount: Int
    let checkedCount: Int
    let totalPrice: String

    private let backgroundColor = Color(red: 245/255, green: 242/255, blue: 220/255)

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 0) {
                // Items count section
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(itemCount)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text(itemCount == 1 ? "Item" : "Items")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Vertical divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)

                // Checked count section
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("\(checkedCount)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text("Checked")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Vertical divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)

                // Total price section
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text(totalPrice)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text("Total")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(backgroundColor)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TotalsSummaryView(
            itemCount: 5,
            checkedCount: 2,
            totalPrice: "$23.45"
        )
    }
}
