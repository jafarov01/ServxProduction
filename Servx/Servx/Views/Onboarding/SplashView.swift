//
//  SplashView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import Foundation
import SwiftUI
struct SplashScreenView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        
        VStack(spacing: 16) {
            // Logo Image
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 186, height: 186)

            // Text Views
            ServxTextView(
                text: "Professional Service.",
                color: Color("primary500"),
                size: 30,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16), lineSpacing: 4,
                kerning: 1
            )
            ServxTextView(
                text: "Fair Price.",
                color: Color("primary500"),
                size: 30,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16), lineSpacing: 4,
                kerning: 1
            )
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
