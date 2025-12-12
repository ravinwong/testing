//
//  ShoppingNoteView.swift
//  ShoppingNotes
//
//  Created by Claude on 2024.
//

import SwiftUI

struct ShoppingNoteView: View {
    @StateObject private var viewModel = ShoppingViewModel()
    @State private var newItemText: String = ""
    @FocusState private var isInputFocused: Bool

    // Apple Notes yellow color
    private let notesYellow = Color(red: 255/255, green: 252/255, blue: 225/255)
    private let lineColor = Color(red: 220/255, green: 218/255, blue: 195/255)

    var body: some View {
        NavigationStack {
            ZStack {
                // Background - Apple Notes paper texture
                notesYellow
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Title area
                    titleSection

                    // Lined paper content
                    linedPaperContent

                    // Bottom totals bar
                    TotalsSummaryView(
                        itemCount: viewModel.totalItems,
                        checkedCount: viewModel.checkedItems,
                        totalPrice: viewModel.formattedTotalPrice
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: clearAllItems) {
                            Label("Clear All", systemImage: "trash")
                        }
                        Button(action: clearCheckedItems) {
                            Label("Clear Checked", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .tint(.orange)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 4) {
            TextField("Title", text: $viewModel.noteTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 16)

            Text(formattedDate)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            Divider()
                .background(lineColor)
        }
    }

    // MARK: - Lined Paper Content

    private var linedPaperContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.items) { item in
                        ItemRowView(
                            item: item,
                            onToggle: { viewModel.toggleCheck(for: item) },
                            onDelete: { viewModel.deleteItem(item) }
                        )
                        .id(item.id)
                    }

                    // New item input row
                    newItemInputRow
                        .id("newItemInput")
                }
                .padding(.top, 8)
            }
            .onChange(of: viewModel.items.count) { _, _ in
                withAnimation {
                    proxy.scrollTo("newItemInput", anchor: .bottom)
                }
            }
        }
    }

    // MARK: - New Item Input

    private var newItemInputRow: some View {
        HStack(spacing: 12) {
            // Empty checkbox placeholder
            Circle()
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 22, height: 22)

            TextField("Add item (e.g., Milk $3.99)", text: $newItemText)
                .font(.system(size: 17))
                .focused($isInputFocused)
                .submitLabel(.done)
                .onSubmit {
                    addNewItem()
                }

            if !newItemText.isEmpty {
                Button(action: addNewItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            VStack {
                Spacer()
                lineColor
                    .frame(height: 1)
            }
        )
    }

    // MARK: - Helper Methods

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    private func addNewItem() {
        viewModel.addItem(from: newItemText)
        newItemText = ""
    }

    private func clearAllItems() {
        withAnimation {
            viewModel.items.removeAll()
        }
    }

    private func clearCheckedItems() {
        withAnimation {
            viewModel.items.removeAll { $0.isChecked }
        }
    }
}

#Preview {
    ShoppingNoteView()
}
