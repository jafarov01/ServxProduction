//
//  MultiSelectDropdownView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 22..
//

import SwiftUI

struct MultiSelectDropdownView: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(Color("primary500"))

            // Dropdown Button
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(selectedOptions.isEmpty ? "Select Options" : selectedOptions.joined(separator: ", "))
                        .foregroundColor(selectedOptions.isEmpty ? Color("primary300") : .black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("primary300"))
                }
                .padding()
                .background(Color("primary100"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("primary500"), lineWidth: 1)
                )
            }

            // Options List
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(selectedOptions.contains(option) ? .black : Color("primary300"))
                                    .fontWeight(selectedOptions.contains(option) ? .bold : .regular)
                                Spacer()
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("primary500"))
                                }
                            }
                            .padding()
                            .background(selectedOptions.contains(option) ? Color("primary100") : .clear)
                            .cornerRadius(8)
                        }
                    }
                }
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
        .animation(.easeInOut, value: isExpanded)
    }
}
