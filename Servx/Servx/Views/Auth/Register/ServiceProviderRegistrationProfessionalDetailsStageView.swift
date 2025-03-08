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
                    ForEach(viewModel.profiles.indices, id: \.self) { index in
                        profileForm(for: index)
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

    // MARK: - Helper Functions
    @ViewBuilder
    private func profileForm(for index: Int) -> some View {
        VStack(spacing: 16) {
            Text("Profile \(index + 1)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                .foregroundColor(Color("primary500"))

            // Service Category Selection
            ObjectOptionSelectionView(
                title: "Service Category",
                options: viewModel.serviceCategoryOptions,
                selectedOptionId: serviceCategoryBinding(for: index)
            )

            // Service Area(s) Selection
            MultiSelectDropdownView<ServiceArea>(
                            title: "Service Area(s)",
                            options: viewModel.serviceAreaOptions,
                            selectedOptionIds: serviceAreasBinding(for: index)
                        )

            // Work Experience Selection (unchanged)
            OptionSelectionView(
                title: "Work Experience",
                options: viewModel.workExperienceOptions,
                selectedOption: $viewModel.profiles[index].workExperience
            )
        }
        .padding()
        .background(Color("primary100"))
        .cornerRadius(12)
    }

    private func serviceCategoryBinding(for index: Int) -> Binding<Int64?> {
        Binding(
            get: { viewModel.profiles[index].serviceCategoryId },
            set: { newValue in
                viewModel.profiles[index].serviceCategoryId = newValue ?? 0
                viewModel.updateSelectedCategory(id: Int(newValue ?? 0))
            }
        )
    }

    private func serviceAreasBinding(for index: Int) -> Binding<Set<Int64>> {
        Binding(
            get: { Set(viewModel.profiles[index].serviceAreaIds) },
            set: { newValue in
                viewModel.profiles[index].serviceAreaIds = Array(newValue)
            }
        )
    }
}
