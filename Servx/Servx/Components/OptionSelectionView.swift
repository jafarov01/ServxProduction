//
//  OptionSelectionView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct OptionSelectionView: View {
    var title: String
    var options: [String]
    @Binding var selectedOption: String
    @State private var isPickerPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ServxTextView(
                text: title,
                color: Color("primary300"),
                size: 16,
                weight: .bold
            )

            Button(action: {
                isPickerPresented = true
            }) {
                HStack {
                    Text(selectedOption.isEmpty ? "Select \(title.lowercased())" : selectedOption)
                        .foregroundColor(selectedOption.isEmpty ? .gray : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color("primary100"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("primary300"), lineWidth: 1)
                )
            }
            .sheet(isPresented: $isPickerPresented) {
                PickerView(
                    title: title,
                    options: options,
                    selectedOption: $selectedOption
                )
            }
        }
    }
}

struct PickerView: View {
    var title: String
    var options: [String]
    @Binding var selectedOption: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        dismiss()
                    }) {
                        Text(option)
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Select \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
