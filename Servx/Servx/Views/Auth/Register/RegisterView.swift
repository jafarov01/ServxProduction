//
//  RegisterView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//
import SwiftUI

struct RegisterView: View {
    @State private var isServiceSeeker: Bool = true
    @StateObject private var viewModel: RegisterViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    init(viewModel: @autoclosure @escaping () -> RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 16) {
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

            // Title
            ServxTextView(
                text: "Create Profile",
                color: Color("primary500"),
                size: 32,
                weight: .bold,
                alignment: .center
            )
            .padding(.top, 16)

            // Role Selection Buttons
            HStack(spacing: 16) {
                ServxButtonView(
                    title: "Service Seeker",
                    width: 163,
                    height: 40,
                    frameColor: Color("primary500"),
                    innerColor: isServiceSeeker ? Color("primary500") : .white,
                    textColor: isServiceSeeker ? .white : Color("greyScale500"),
                    cornerRadius: 8,
                    action: { isServiceSeeker = true }
                )

                ServxButtonView(
                    title: "Service Provider",
                    width: 163,
                    height: 40,
                    frameColor: Color("primary500"),
                    innerColor: !isServiceSeeker ? Color("primary500") : .white,
                    textColor: !isServiceSeeker ? .white : Color("greyScale500"),
                    cornerRadius: 8,
                    action: { isServiceSeeker = false }
                )
            }

            // Dynamic Input View
            ScrollView {
                VStack {
                    if isServiceSeeker {
                        ServiceSeekerRegistrationView(viewModel: viewModel)
                    } else {
                        ServiceProviderRegistrationView(viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // Footer
            ServiceAuthView(hasAccount: false)
        }
        .navigationBarBackButtonHidden(true)
    }
}
