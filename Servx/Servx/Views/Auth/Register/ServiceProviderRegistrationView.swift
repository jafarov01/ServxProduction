////
////  ServiceProviderRegistrationView.swift
////  Servx
////
////  Created by Makhlug Jafarov on 2024. 12. 01..
////
//
//import SwiftUI
//
//enum RegistrationStage {
//    case initial
//    case profileDetails
//    case professionalDetails
//}
//
//struct ServiceProviderRegistrationView: View {
//    @ObservedObject var viewModel: RegisterViewModel
//    @State private var currentStage: RegistrationStage = .initial
//    @EnvironmentObject private var navigationManager: NavigationManager
//
//    var body: some View {
//        
//        HStack {
//            Button(action: {
//                navigationManager.goBack()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.blue)
//                    .padding()
//            }
//            .padding(.leading, 10)
//            
//            Spacer()
//        }
//        .frame(height: 44)
//        
//        VStack {
//            switch currentStage {
//            case .initial:
//                ServiceProviderRegistrationInitialStageView(viewModel: viewModel) {
//                    currentStage = .profileDetails
//                }
//            case .profileDetails:
//                ServiceProviderRegistrationProfileDetailsStageView(viewModel: viewModel) {
//                    currentStage = .professionalDetails
//                }
//            case .professionalDetails:
//                ServiceProviderRegistrationProfessionalDetailsStageView(viewModel: viewModel) {
//                    viewModel.completeRegistration()
//                }
//            }
//        }
//        .padding(24)
//        .navigationBarBackButtonHidden(true)
//    }
//}
