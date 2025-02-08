//
//  ObjectOptionSelectionView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 02. 07..
//

import SwiftUI
import Foundation

protocol SelectableOption: Identifiable, Hashable {
    var id: Int64 { get }
    var name: String { get }
}

struct ObjectOptionSelectionView<T: SelectableOption>: View {
    var title: String
    var options: [T]
    @Binding var selectedOptionId: Int64?  // Binding to the selected option's id
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
                    Text(selectedOptionId == nil ? "Select \(title.lowercased())" : options.first { $0.id == selectedOptionId! }?.name ?? "")
                        .foregroundColor(selectedOptionId == nil ? .gray : .black)
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
                LazyObjectPickerView(
                    title: title,
                    options: options,
                    selectedOptionId: $selectedOptionId
                )
            }
        }
    }
}

struct LazyObjectPickerView<T: SelectableOption>: View {
    var title: String
    var options: [T]
    @Binding var selectedOptionId: Int64?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(options) { option in
                Button(action: {
                    selectedOptionId = option.id
                    dismiss()
                }) {
                    Text(option.name)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
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
