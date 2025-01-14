//
//  SubcategoriesView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

struct SubcategoriesView: View {
    var category: ServiceCategory
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 16) {
            
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
            
            // Title
            HStack {
                ServxTextView(
                    text: "Choose a subcategory",
                    color: ServxTheme.blackColor,
                    size: 16,
                    weight: .bold,
                    alignment: .leading
                )
                Spacer()
            }
            .padding(.horizontal, 24)

            Spacer()

            // Subcategories List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(category.subcategories, id: \.name) { subcategory in
                        Button(action: {
                            navigationManager.navigate(
                                to: .services(category: category, subcategory: subcategory)
                            )
                        }) {
                            HStack {
                                // Subcategory Name
                                ServxTextView(
                                    text: subcategory.name,
                                    color: ServxTheme.blackColor,
                                    size: 16,
                                    weight: .regular,
                                    alignment: .leading
                                )
                                .padding(.leading, 24)

                                Spacer()

                                // Arrow Icon
                                Image("arrowIcon")
                                    .padding(.trailing, 24)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle(category.name)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let navigationManager = NavigationManager()
    SubcategoriesView(category: ServxStaticData.serviceCategories[0])
        .environmentObject(navigationManager)
}
