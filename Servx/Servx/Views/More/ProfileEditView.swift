//
//  ProfileEditView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject private var viewModel : ProfileEditViewModel
    @EnvironmentObject private var navigator: NavigationManager
    
    init(viewModel: ProfileEditViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                navigationHeader
                photoSection
                personalInfoSection
                addressSection
                saveButton
            }
            .padding()
        }
        .onChange(of: viewModel.didComplete) { _, newValue in
            if newValue {
                navigator.goBack()
            }
        }
        .background(ServxTheme.backgroundColor)
        .navigationBarHidden(true)
        .debugRender("ProfileEditView")
    }
    
    private var photoSection: some View {
        VStack(spacing: 16) {
            ServxTextView(
                text: "Profile Photo",
                color: ServxTheme.primaryColor,
                size: 18,
                weight: .semibold
            )

            Button {
                navigator.navigate(to: AppRoute.More.photoEdit)
            } label: {
                ProfilePhotoView(imageUrl: AuthenticatedUser.shared.currentUser?.profilePhotoUrl)
                    .overlay(
                        Circle()
                            .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
    
    private var navigationHeader: some View {
        HStack {
            Button {
                navigator.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(ServxTheme.primaryColor)
                    .padding()
            }
            
            ServxTextView(
                text: "Edit Profile",
                color: ServxTheme.primaryColor,
                size: 20,
                weight: .bold
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    private var personalInfoSection: some View {
        VStack(spacing: 16) {
            ServxTextView(
                text: "Personal Information",
                color: ServxTheme.primaryColor,
                size: 18,
                weight: .semibold
            )
            
            ServxInputView(
                text: $viewModel.firstName,
                placeholder: "First Name",
                frameColor: ServxTheme.inputFieldBorderColor,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.blackColor
            )
            
            ServxInputView(
                text: $viewModel.lastName,
                placeholder: "Last Name",
                frameColor: ServxTheme.inputFieldBorderColor,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.blackColor
            )
            
            ServxInputView(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                frameColor: ServxTheme.inputFieldBorderColor,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.blackColor,
                keyboardType: .phonePad
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
    
    private var addressSection: some View {
        VStack(spacing: 16) {
            ServxTextView(
                text: "Address Information",
                color: ServxTheme.primaryColor,
                size: 18,
                weight: .semibold
            )
            
            ServxInputView(
                text: $viewModel.streetAddress,
                placeholder: "Street Address",
                frameColor: ServxTheme.inputFieldBorderColor,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.blackColor
            )
            
            HStack(spacing: 16) {
                ServxInputView(
                    text: $viewModel.city,
                    placeholder: "City",
                    frameColor: ServxTheme.inputFieldBorderColor,
                    backgroundColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.blackColor
                )
                
                ServxInputView(
                    text: $viewModel.zipCode,
                    placeholder: "ZIP Code",
                    frameColor: ServxTheme.inputFieldBorderColor,
                    backgroundColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.blackColor,
                    keyboardType: .numberPad
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
    
    private var saveButton: some View {
        ServxButtonView(
            title: "Save Changes",
            width: UIScreen.main.bounds.width - 32,
            height: 50,
            frameColor: viewModel.isValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            innerColor: viewModel.isValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            textColor: .white,
            isDisabled: !viewModel.isValid,
            action: { Task { await viewModel.saveChanges() } }
        )
    }
}
