//
//  ServxButtonView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import Foundation
import SwiftUI

struct ServxButtonView: View {
    var title: String
    var width: CGFloat
    var height: CGFloat
    var frameColor: Color
    var innerColor: Color
    var textColor: Color
    var font: Font = .headline
    var cornerRadius: CGFloat = 10
    var icon: Image? = nil
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(textColor)
                }
                Text(title)
                    .font(font)
                    .foregroundColor(textColor)
            }
            .frame(width: width, height: height)
            .background(innerColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(frameColor, lineWidth: 2)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}
