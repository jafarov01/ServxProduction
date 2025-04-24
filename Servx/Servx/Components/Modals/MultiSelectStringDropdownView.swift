//
//  salam.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 08..
//

import SwiftUI
import Foundation

struct MultiSelectStringDropdownView: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: [String]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("primary500"))
            
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(selectedOptions.isEmpty ? "Select \(title)" : selectedOptions.joined(separator: ", "))
                        .foregroundColor(selectedOptions.isEmpty ? Color("primary300") : .black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .dropdownButtonStyle()
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { toggle(option) }) {
                            HStack {
                                Text(option)
                                Spacer()
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                        .background(selectedOptions.contains(option) ? Color("primary100") : .clear)
                    }
                }
                .dropdownListStyle()
            }
        }
        .animation(.easeInOut, value: isExpanded)
    }

    private func toggle(_ option: String) {
        withAnimation {
            if let index = selectedOptions.firstIndex(of: option) {
                selectedOptions.remove(at: index)
            } else {
                selectedOptions.append(option)
            }
        }
    }
}
