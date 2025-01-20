//
//  CategoryButton.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

struct CategoryButton: View {
    var categoryName: String
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(ServxTheme.primaryColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(categoryName.prefix(1))
                        .font(.title)
                        .foregroundColor(.white)
                )

            ServxTextView(
                text: categoryName,
                color: ServxTheme.blackColor,
                size: 14,
                weight: .regular,
                alignment: .center
            )
        }
        .frame(width: 100)
        .padding(.vertical, 8)
    }
}

#Preview {
    CategoryButton(categoryName: "SALAM")
}
