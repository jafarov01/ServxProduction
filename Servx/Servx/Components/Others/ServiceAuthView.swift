//
//  ServiceAuthView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//
import SwiftUI

struct ServiceAuthView: View {
    var hasAccount: Bool
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 16) {
            // Divider with text
            HStack {
                Divider()
                    .frame(height: 1)
                    .background(Color("greyScale300"))

                ServxTextView(
                    text: hasAccount ? "or sign in with" : "or sign up with",
                    color: Color("greyScale500"),
                    size: 12,
                    weight: .regular,
                    alignment: .center
                )

                Divider()
                    .frame(height: 1)
                    .background(Color("greyScale300"))
            }

            // Social Auth Buttons
            HStack(spacing: 16) {
                ServiceButtonView(image: "authGoogle") {
                    print("Google Sign-In triggered")
                }
                ServiceButtonView(image: "authApple") {
                    print("Apple Sign-In triggered")
                }
                ServiceButtonView(image: "authFacebook") {
                    print("Facebook Sign-In triggered")
                }
            }

            // Navigation Section
            HStack(spacing: 4) {
                if hasAccount {
                    ServxTextView(
                        text: "Don't have an account?",
                        color: Color("primary400"),
                        size: 13,
                        weight: .regular
                    )
                    ServxButtonView(
                        title: "Sign up",
                        width: 80,
                        height: 20,
                        frameColor: .clear,
                        innerColor: .clear,
                        textColor: Color("secondary500"),
                        action: {
                            navigationManager.navigateTo(.register)
                        }
                    )
                } else {
                    ServxTextView(
                        text: "Have an account?",
                        color: Color("primary400"),
                        size: 13,
                        weight: .regular
                    )
                    ServxButtonView(
                        title: "Sign in",
                        width: 80,
                        height: 20,
                        frameColor: .clear,
                        innerColor: .clear,
                        textColor: Color("secondary500"),
                        action: {
                            navigationManager.goBack()
                        }
                    )
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }
}
