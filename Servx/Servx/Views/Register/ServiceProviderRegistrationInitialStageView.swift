//
//  ServiceProviderRegistrationInitialStageView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceProviderRegistrationInitialStageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var viewModel: RegisterViewModel
    var onNext: () -> Void

    var body: some View {
        
        HStack {
            Button(action: {
                navigationManager.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .frame(height: 44)
        
        VStack(spacing: 24) {
            ServxInputView(
                text: $viewModel.email,
                placeholder: "Email",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .emailAddress
            )

            ServxInputView(
                text: $viewModel.password,
                placeholder: "Password",
                isSecure: true,
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )

            ServxButtonView(
                title: "Next",
                width: 200,
                height: 50,
                frameColor: viewModel.isInitialStageValid ? Color("primary500") : .gray,
                innerColor: viewModel.isInitialStageValid ? Color("primary500") : .gray,
                textColor: .white,
                cornerRadius: 12,
                isDisabled: !viewModel.isInitialStageValid,
                action: {
                    if viewModel.isInitialStageValid {
                        onNext()
                    }
                }
            )
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}
