//
//  OnboardingView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var currentPage = 0

    var body: some View {
        
        HStack {
            Button(action: {
                navigationManager.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .frame(height: 44)
        
        VStack {
            // Tab View for Onboarding Pages
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "onboardingOne",
                    title: "The right choice for you.",
                    description: "Customers are like teeth. If you don't take care of them they go away one by one until there are none.",
                    tag: 0
                )
                OnboardingPageView(
                    imageName: "onboardingTwo",
                    title: "Give more than Expected",
                    description: "Customers don’t care how much you know unless they know how much you care.” Damon Richards",
                    tag: 1
                )
                OnboardingPageView(
                    imageName: "onboardingThree",
                    title: "We prefer the helpful ways",
                    description: "If you don’t appreciate your customers, someone else will",
                    tag: 2
                )
                OnboardingPageView(
                    imageName: "onboardingFour",
                    title: "Power full of Satisfaction",
                    description: "One customer well taken care of could be more valuable than $10,000 worth of advertising",
                    tag: 3
                )
            }
            .tabViewStyle(PageTabViewStyle())

            // Next Button
            ServxButtonView(
                title: "Next",
                width: 300,
                height: 50,
                frameColor: Color("primary600"),
                innerColor: Color("primary600"),
                textColor: .white,
                font: .headline,
                cornerRadius: 12,
                action: {
                    if currentPage < 3 {
                        currentPage += 1
                    } else {
                        navigationManager.navigate(to: .authentication)
                    }
                }
            )
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingPageView: View {
    var imageName: String
    var title: String
    var description: String
    var tag: Int

    var body: some View {
        VStack(spacing: 16) {
            // Image
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 273, height: 349)

            // Title Text
            ServxTextView(
                text: title,
                color: Color("primary500"),
                size: 30,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16), lineSpacing: 4
            )

            // Description Text
            ServxTextView(
                text: description,
                color: Color("grey500"),
                size: 20,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16), lineSpacing: 4
            )
        }
        .tag(tag)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
