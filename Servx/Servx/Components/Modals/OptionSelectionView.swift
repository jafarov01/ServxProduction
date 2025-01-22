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
            // Title
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("primary300"))

            // Selection Button
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
                LazyPickerView(
                    title: title,
                    options: options,
                    selectedOption: $selectedOption
                )
            }
        }
    }
}

struct LazyPickerView: View {
    var title: String
    var options: [String]
    @Binding var selectedOption: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            dismiss()
                        }) {
                            Text(option)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                }
                .padding()
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
