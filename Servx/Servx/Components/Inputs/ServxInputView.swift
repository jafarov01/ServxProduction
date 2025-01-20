//
//  ServxInputView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServxInputView: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var frameWidth: CGFloat? = nil
    var frameColor: Color = .gray
    var backgroundColor: Color = .white
    var textColor: Color = .black
    var keyboardType: UIKeyboardType = .default
    var cornerRadius: CGFloat = 8
    var paddingValues: EdgeInsets = EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(paddingValues)
                    .frame(maxWidth: frameWidth)
                    .background(backgroundColor)
                    .foregroundColor(textColor)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(frameColor, lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding(paddingValues)
                    .frame(maxWidth: frameWidth)
                    .background(backgroundColor)
                    .foregroundColor(textColor)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(frameColor, lineWidth: 1)
                    )
            }
        }
    }
}
