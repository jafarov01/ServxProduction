//
//  ServiceProviderRegistrationProfileDetailsStageView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceProviderRegistrationProfileDetailsStageView: View {
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
            ServxInputView(text: $viewModel.firstName, placeholder: "First Name", frameColor: Color("primary100"), backgroundColor: .white, textColor: Color("primary300"))
            ServxInputView(text: $viewModel.lastName, placeholder: "Last Name", frameColor: Color("primary100"), backgroundColor: .white, textColor: Color("primary300"))
            ServxInputView(text: $viewModel.phoneNumber, placeholder: "Phone Number", frameColor: Color("primary100"), backgroundColor: .white, textColor: Color("primary300"))
            ServxInputView(text: $viewModel.country, placeholder: "Country", frameColor: Color("primary100"), backgroundColor: .white, textColor: Color("primary300"))
            ServxInputView(text: $viewModel.city, placeholder: "City", frameColor: Color("primary100"), backgroundColor: .white, textColor: Color("primary300"))

//            ServxButtonView(
//                title: "Next",
//                width: 200,
//                height: 50,
//                frameColor: viewModel.isProfileDetailsStageValid ? Color("primary500") : .gray,
//                innerColor: viewModel.isProfileDetailsStageValid ? Color("primary500") : .gray,
//                textColor: .white,
//                cornerRadius: 12,
//                isDisabled: !viewModel.isProfileDetailsStageValid,
//                action: {
//                    if viewModel.isProfileDetailsStageValid {
//                        onNext()
//                    }
//                }
//            )
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}
