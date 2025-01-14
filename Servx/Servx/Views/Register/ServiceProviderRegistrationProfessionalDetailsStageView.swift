//
//  ServiceProviderRegistrationProfessionalDetailsStageView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceProviderRegistrationProfessionalDetailsStageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var viewModel: RegisterViewModel
    var onComplete: () -> Void

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
            OptionSelectionView(title: "Education", options: viewModel.educationOptions, selectedOption: $viewModel.selectedEducation)
            OptionSelectionView(title: "Service Area", options: viewModel.serviceAreaOptions, selectedOption: $viewModel.selectedServiceArea)
            OptionSelectionView(title: "Language", options: viewModel.languageOptions, selectedOption: $viewModel.selectedLanguage)
            OptionSelectionView(title: "Work Experience", options: viewModel.workExperienceOptions, selectedOption: $viewModel.selectedWorkExperience)

            ServxButtonView(
                title: "Complete",
                width: 200,
                height: 50,
                frameColor: viewModel.isProfessionalDetailsStageValid ? Color("primary500") : .gray,
                innerColor: viewModel.isProfessionalDetailsStageValid ? Color("primary500") : .gray,
                textColor: .white,
                cornerRadius: 12,
                isDisabled: !viewModel.isProfessionalDetailsStageValid,
                action: {
                    if viewModel.isProfessionalDetailsStageValid {
                        onComplete()
                    }
                }
            )
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}
