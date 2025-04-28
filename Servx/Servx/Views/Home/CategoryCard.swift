//
//  CategoryCard.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

enum ServiceCategoryColor {
    case cleaning, repairing, shifting, painting, appliance, plumbing, more, laundry
    
    var color: Color {
        switch self {
        case .cleaning:
            return Color(hex: 0x1D2E45).opacity(0.08)
        case .repairing:
            return Color(hex: 0xF6C675).opacity(0.08)
        case .shifting, .painting:
            return Color(hex: 0x30AABD).opacity(0.08)
        case .appliance:
            return Color(hex: 0xD63031).opacity(0.08)
        case .plumbing, .laundry:
            return Color(hex: 0x4CAF50).opacity(0.08)
        case .more:
            return Color(hex: 0x120869).opacity(0.08)
        }
    }   
    
    init?(categoryName: String) {
        switch categoryName.lowercased() {
        case "cleaning":
            self = .cleaning
        case "repairing":
            self = .repairing
        case "shifting":
            self = .shifting
        case "painting":
            self = .painting
        case "appliance":
            self = .appliance
        case "plumbing":
            self = .plumbing
        case "more":
            self = .more
        case "laundry":
            self = .laundry
        default:
            return nil
        }
    }
}

extension Color {
    init(hex: Int) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

struct CategoryCard: View {
    let category: ServiceCategory
    
    var body: some View {
        VStack(spacing: 8) {
            Image(category.name.lowercased())
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text(category.name)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(12)
        .background(ServiceCategoryColor(categoryName: category.name)?.color)
        .cornerRadius(12)
    }
}
