//
//  BackButton.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 13..
//

import SwiftUI
import Foundation

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
                .padding()
        }
    }
}
