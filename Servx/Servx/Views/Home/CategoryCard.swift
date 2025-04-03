//
//  CategoryCard.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct CategoryCard: View {
    let category: ServiceCategory
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text(category.name)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
