//
//  ServiceDetailedCard.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ServiceDetailedCard: View {
    let service: ServiceProfile
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.serviceTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("greyScale900"))
                    
                    Text(service.providerName ?? "Unknown Provider")
                        .font(.system(size: 14))
                        .foregroundColor(Color("greyScale700"))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        
                        Text("\(service.rating, specifier: "%.1f") | \(service.reviewCount) reviews")
                            .font(.system(size: 12))
                            .foregroundColor(Color("greyScale700"))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(service.price, specifier: "%.0f")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("primary500"))
                    
                    Button(action: { /* Add to cart logic here */ }) {
                        Text("Add")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("primary300"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}
