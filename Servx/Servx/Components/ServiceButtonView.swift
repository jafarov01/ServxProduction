//
//  ServiceButtonView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceButtonView: View {
    var image: String
    var handler: () -> Void

    var body: some View {
        Button(action: handler) {
            Image(image)
                .frame(width: 36, height: 36)
        }
    }
}
