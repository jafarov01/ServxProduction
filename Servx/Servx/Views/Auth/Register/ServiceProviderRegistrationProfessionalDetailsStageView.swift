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
        VStack(spacing: 16) {
            // Navigation Back Button
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Forms
                    ForEach(viewModel.profiles.indices, id: \.self) { index in
                        VStack(spacing: 16) {
                            Text("Profile \(index + 1)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 8)
                            
                            OptionSelectionView(
                                title: "Education",
                                options: viewModel.educationOptions,
                                selectedOption: $viewModel.profiles[index].education
                            )
                            OptionSelectionView(
                                title: "Service Category",
                                options: viewModel.serviceCategoryOptions,
                                selectedOption: $viewModel.profiles[index].serviceCategory
                            )
                            OptionSelectionView(
                                title: "Service Area",
                                options: viewModel.serviceAreaOptions,
                                selectedOption: $viewModel.profiles[index].serviceAreas[0] // Example for first area
                            )
                            OptionSelectionView(
                                title: "Work Experience",
                                options: viewModel.workExperienceOptions,
                                selectedOption: $viewModel.profiles[index].workExperience
                            )
                        }
                        .padding()
                        .background(Color("primary100"))
                        .cornerRadius(12)
                        
                        // Remove Button for Additional Profiles
                        if index > 0 {
                            Button(action: {
                                viewModel.removeProfile(at: index)
                            }) {
                                Text("Remove Profile")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    // Add Profile Button
                    ServxButtonView(
                        title: "Add Profile",
                        width: 200,
                        height: 50,
                        frameColor: Color("primary500"),
                        innerColor: Color("primary500"),
                        textColor: .white,
                        cornerRadius: 12,
                        action: {
                            viewModel.addProfile()
                        }
                    )
                    
                    // Complete Registration Button
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
            }
        }
        .onAppear {
            viewModel.ensureAtLeastOneProfile()
        }
        .navigationBarBackButtonHidden(true)
    }
}
