//
//  MainBottomNavBar.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 05..
//


import SwiftUI

struct MainBottomNavBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        ZStack {
            VStack {
                CustomBottomTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
        }
    }
}

struct CustomBottomTabBar: View {
    @Binding var selectedTab: Tab

    private var activeImage: String {
        return selectedTab.rawValue + "Active"
    }

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()

                Image((selectedTab == tab ? activeImage : tab.rawValue + "Inactive"))
                    .resizable()
                    .frame(width: 36, height: 36)
                    .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                    .padding(.bottom, 10)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.5)) {
                            selectedTab = tab
                        }
                    }

                Spacer()
            }
        }
        .frame(height: 70)
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
