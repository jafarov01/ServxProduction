//
//  SubcategoryRow.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct SubcategoryRow: View {
    let subcategory: Subcategory
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(subcategory.name)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("greyScale900"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("greyScale400"))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
}
