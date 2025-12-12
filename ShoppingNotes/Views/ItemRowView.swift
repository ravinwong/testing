//
//  ItemRowView.swift
//  ShoppingNotes
//
//  Created by Claude on 2024.
//

import SwiftUI

struct ItemRowView: View {
    @Binding var item: ShoppingItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTextChange: (String) -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwiping: Bool = false
    @FocusState private var isEditing: Bool

    private let lineColor = Color(red: 220/255, green: 218/255, blue: 195/255)
    private let deleteThreshold: CGFloat = -80

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 44)
                        .background(Color.red)
                }
            }

            // Main content
            HStack(spacing: 12) {
                // Checkbox
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(item.isChecked ? Color.orange : Color.gray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 22, height: 22)

                        if item.isChecked {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 16, height: 16)

                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Editable item text
                TextField("Item", text: $item.text)
                    .font(.system(size: 17))
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                    .strikethrough(item.isChecked, color: .secondary)
                    .focused($isEditing)
                    .onChange(of: item.text) { _, newValue in
                        onTextChange(newValue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Price badge (if recognized)
                if item.recognizedPrice != nil {
                    Text(item.displayPrice)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(item.isChecked ? Color.gray : Color.orange)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 255/255, green: 252/255, blue: 225/255))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                            isSwiping = true
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if value.translation.width < deleteThreshold {
                                offset = -80
                            } else {
                                offset = 0
                            }
                            isSwiping = false
                        }
                    }
            )
            .onTapGesture {
                if offset < 0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                    }
                }
            }
        }
        .background(
            VStack {
                Spacer()
                lineColor
                    .frame(height: 1)
            }
        )
    }
}

#Preview {
    @Previewable @State var item1 = ShoppingItem(text: "Milk $3.99", recognizedPrice: 3.99)
    @Previewable @State var item2 = ShoppingItem(text: "Eggs $5.49", recognizedPrice: 5.49, isChecked: true)
    @Previewable @State var item3 = ShoppingItem(text: "Bread (no price)", recognizedPrice: nil)

    VStack(spacing: 0) {
        ItemRowView(
            item: $item1,
            onToggle: {},
            onDelete: {},
            onTextChange: { _ in }
        )
        ItemRowView(
            item: $item2,
            onToggle: {},
            onDelete: {},
            onTextChange: { _ in }
        )
        ItemRowView(
            item: $item3,
            onToggle: {},
            onDelete: {},
            onTextChange: { _ in }
        )
    }
    .background(Color(red: 255/255, green: 252/255, blue: 225/255))
}
