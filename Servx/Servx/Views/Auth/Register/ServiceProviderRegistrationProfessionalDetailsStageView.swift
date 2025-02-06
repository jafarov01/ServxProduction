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
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Forms
                    ForEach(viewModel.profiles.indices, id: \.self) { index in
                        VStack(spacing: 16) {
                            Text("Profile \(index + 1)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 8)
                                .foregroundColor(Color("primary500"))

                            OptionSelectionView(
                                title: "Service Category",
                                options: viewModel.serviceCategoryOptions.map { $0.name },
                                selectedOption: Binding(
                                    get: { viewModel.profiles[index].serviceCategoryId > 0 ? "\(viewModel.profiles[index].serviceCategoryId)" : "" },
                                    set: { newValue in
                                        if let id = Int(newValue) {
                                            viewModel.profiles[index].serviceCategoryId = id
                                            viewModel.updateSelectedCategory(id: id) // fetch areas after category change
                                        }
                                    }
                                )
                            )

                            OptionSelectionView(
                                title: "Service Area(s)",
                                options: viewModel.serviceAreaOptions.map { $0.name },
                                selectedOption: Binding(
                                    get: { viewModel.profiles[index].serviceAreaIds.first.map { "\($0)" } ?? "" },
                                    set: { newValue in
                                        if let id = Int(newValue) {
                                            viewModel.profiles[index].serviceAreaIds = [id]
                                        }
                                    }
                                )
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

                        // remove button for additional profiles
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

                    // Next Button
                    ServxButtonView(
                        title: "Next",
                        width: 200,
                        height: 50,
                        frameColor: viewModel.isProfessionalDetailsStageValid ? Color("primary500") : .gray,
                        innerColor: viewModel.isProfessionalDetailsStageValid ? Color("primary500") : .gray,
                        textColor: .white,
                        cornerRadius: 12,
                        isDisabled: !viewModel.isProfessionalDetailsStageValid,
                        action: {
                            if viewModel.isProfessionalDetailsStageValid {
                                onNext()
                            }
                        }
                    )
                }
                .padding(24)
            }
        }
        .onAppear {
            viewModel.ensureAtLeastOneProfile()
            viewModel.fetchServiceData()
        }
        .navigationBarBackButtonHidden(true)
    }
}
