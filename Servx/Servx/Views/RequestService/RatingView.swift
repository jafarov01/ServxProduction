//
//  RatingView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
            }
        }
    }
}
