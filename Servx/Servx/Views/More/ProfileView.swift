//
//  ProfileDetailView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var navigator: NavigationManager
    @StateObject private var viewModel = ProfileViewModel()

    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                personalInfoSection
                Spacer()
            }
            .padding()
        }
        .background(ServxTheme.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ServxButtonView(
                    title: "Edit",
                    width: 80,
                    height: 40,
                    frameColor: ServxTheme.primaryColor,
                    innerColor: Color.clear,
                    textColor: ServxTheme.primaryColor,
                    action: { navigator.navigate(to: AppRoute.More.editProfile) }
                )
            }
        }
        .debugRender("ProfileView")
    }
    
    @ViewBuilder
    private var profileHeader: some View {
        if let user = viewModel.user {
            VStack(spacing: 16) {
                ProfilePhotoView(imageUrl: AuthenticatedUser.shared.currentUser?.profilePhotoUrl)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 2)
                    )
                
                ServxTextView(
                    text: user.fullName,
                    color: ServxTheme.primaryColor,
                    size: 24,
                    weight: .bold,
                    alignment: .center
                )
            }
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
            
            infoRow(title: "Email", value: viewModel.user?.email ?? "")
            infoRow(title: "Phone", value: viewModel.user?.phoneNumber ?? "")
            infoRow(title: "Address", value: viewModel.user?.address.addressLine ?? "")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            ServxTextView(
                text: title,
                color: ServxTheme.secondaryTextColor,
                size: 16
            )
            Spacer()
            ServxTextView(
                text: value,
                color: ServxTheme.blackColor,
                size: 16,
                alignment: .trailing
            )
        }
        .padding(.vertical, 8)
    }
}
