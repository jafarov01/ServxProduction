//
//  ServxTextView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import Foundation
import SwiftUI

struct ServxTextView: View {
    var text: String
    var color: Color = .black
    var size: CGFloat = 16
    var weight: Font.Weight = .regular
    var alignment: TextAlignment = .leading
    var paddingValues: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    var lineLimit: Int? = nil
    var lineSpacing: CGFloat = 0
    var kerning: CGFloat = 0
    var truncationMode: Text.TruncationMode = .tail

    var body: some View {
        Text(text)
            .foregroundColor(color)
            .font(.system(size: size, weight: weight))
            .multilineTextAlignment(alignment)
            .padding(paddingValues)
            .lineLimit(lineLimit)
            .lineSpacing(lineSpacing)
            .kerning(kerning)
            .truncationMode(truncationMode)
    }
}
