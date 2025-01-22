//
//  ServiceProviderRegistrationView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..


import SwiftUI

enum RegistrationStage {
    case initial
    case profileDetails
    case professionalDetails
}

struct ServiceProviderRegistrationView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @State private var currentStage: RegistrationStage = .initial
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            // Navigation Header
            HStack {
                Button(action: {
                    navigationManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)
            
            // Dynamic Content Based on Stage
            VStack {
                switch currentStage {
                case .initial:
                    ServiceProviderRegistrationInitialStageView(viewModel: viewModel) {
                        currentStage = .profileDetails
                    }
                case .profileDetails:
                    ServiceProviderPersonalDetailsStageView(viewModel: viewModel) {
                        currentStage = .professionalDetails
                    }
                case .professionalDetails:
                    ServiceProviderRegistrationProfessionalDetailsStageView(viewModel: viewModel) {
                        viewModel.registerServiceProvider { success in
                            if success {
                                navigationManager.navigate(to: .authentication)
                            } else {
                                // Handle failure, e.g., show an error message
                                print("Registration failed")
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
    }
}
