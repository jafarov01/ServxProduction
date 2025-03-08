//
//  MultiSelectDropdownView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 22..
//

import SwiftUI

struct MultiSelectDropdownView<T: SelectableOption>: View {
    let title: String
    let options: [T]
    @Binding var selectedOptionIds: Set<Int64>
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(Color("primary500"))

            // Dropdown Button
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(selectedOptionsDisplayText)
                        .foregroundColor(selectedOptionIds.isEmpty ? Color("primary300") : .black)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .dropdownButtonStyle()
            }

            // Options List
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(options) { option in
                        optionRow(for: option)
                    }
                }
                .dropdownListStyle()
            }
        }
        .animation(.easeInOut, value: isExpanded)
    }

    private var selectedOptionsDisplayText: String {
        selectedOptionIds.isEmpty ? "Select \(title)" : options
            .filter { selectedOptionIds.contains($0.id) }
            .map { $0.name }
            .joined(separator: ", ")
    }

    @ViewBuilder
    private func optionRow(for option: T) -> some View {
        Button(action: { toggleSelection(option: option) }) {
            HStack {
                Text(option.name)
                    .foregroundStyle(selectedOptionIds.contains(option.id) ? .black : Color("primary300"))
                Spacer()
                if selectedOptionIds.contains(option.id) {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(8)
        .background(selectedOptionIds.contains(option.id) ? Color("primary100") : .clear)
    }

    private func toggleSelection(option: T) {
        withAnimation {
            if selectedOptionIds.contains(option.id) {
                selectedOptionIds.remove(option.id)
            } else {
                selectedOptionIds.insert(option.id)
            }
        }
    }
}

extension View {
    func dropdownButtonStyle() -> some View {
        self
            .padding()
            .background(Color("primary100"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("primary500"), lineWidth: 1)
            )
    }

    func dropdownListStyle() -> some View {
        self
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("primary500"), lineWidth: 1)
            )
            .shadow(radius: 4)
    }
}
