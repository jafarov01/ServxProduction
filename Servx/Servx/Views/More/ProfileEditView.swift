//
//  ProfileEditView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @State private var showPhotoEditor = false
    @EnvironmentObject private var navManager: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photoSection
                personalInfoSection
                addressSection
                saveButton
            }
            .padding()
        }
        .background(ServxTheme.backgroundColor)
        .navigationBarHidden(true)
        .task { await viewModel.loadUser() }
        .sheet(isPresented: $showPhotoEditor) {
            ProfilePhotoEditView()
                .environmentObject(viewModel)
        }
    }
    
    private var navigationHeader: some View {
        HStack {
            HStack {
                Button(action: {
                    navManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            .frame(height: 44)
            Spacer()
            ServxTextView(
                text: "Edit Profile",
                color: ServxTheme.primaryColor,
                size: 20,
                weight: .bold
            )
            Spacer()
        }
    }
    
    private var photoSection: some View {
            VStack(spacing: 16) {
                ServxTextView(
                    text: "Profile Photo",
                    color: ServxTheme.primaryColor,
                    size: 18,
                    weight: .semibold
                )
                
                Button(action: { showPhotoEditor = true }) {
                    ProfilePhotoView(imageUrl: viewModel.user?.profilePhotoUrl)
                        .frame(width: 120, height: 120)
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
