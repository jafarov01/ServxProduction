//
//  SettingsView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var navManager: NavigationManager
    @State private var darkModeEnabled = false
    @State private var notificationsEnabled = true

    var body: some View {
        VStack(spacing: 32) {
            ServxTextView(
                text: "Settings",
                color: ServxTheme.primaryColor,
                size: 24,
                weight: .bold,
                alignment: .center
            )
            .padding(.top, 40)

            VStack(alignment: .leading, spacing: 16) {
                ServxTextView(
                    text: "ACCOUNT SETTINGS",
                    color: ServxTheme.secondaryTextColor,
                    size: 14,
                    weight: .semibold
                )
                .padding(.leading, 16)

                ServxButtonView(
                    title: "Change Email Address",
                    width: UIScreen.main.bounds.width - 48,
                    height: 56,
                    frameColor: ServxTheme.inputFieldBorderColor,
                    innerColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.primaryColor,
                    isDisabled: true,
                    action: {}
                )
                .opacity(0.5)

                ServxButtonView(
                    title: "Change Password",
                    width: UIScreen.main.bounds.width - 48,
                    height: 56,
                    frameColor: ServxTheme.inputFieldBorderColor,
                    innerColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.primaryColor,
                    isDisabled: true,
                    action: {}
                )
                .opacity(0.5)
            }

            VStack(alignment: .leading, spacing: 16) {
                ServxTextView(
                    text: "APP PREFERENCES",
                    color: ServxTheme.secondaryTextColor,
                    size: 14,
                    weight: .semibold
                )
                .padding(.leading, 16)

                HStack {
                    ServxTextView(
                        text: "Dark Mode",
                        color: ServxTheme.primaryColor,
                        size: 16
                    )
                    Spacer()
                    Toggle("", isOn: $darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: ServxTheme.primaryColor))
                }
                .padding(16)
                .background(ServxTheme.backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 1)
                )

                HStack {
                    ServxTextView(
                        text: "Push Notifications",
                        color: ServxTheme.primaryColor,
                        size: 16
                    )
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: ServxTheme.primaryColor))
                }
                .padding(16)
                .background(ServxTheme.backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 1)
                )
            }

            ServxTextView(
                text: "Servx v1.0.0",
                color: ServxTheme.secondaryTextColor,
                size: 14,
                alignment: .center
            )
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(ServxTheme.greyScale100Color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}
