//
//  SubcategoriesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct SubcategoriesListView: View {
    let category: ServiceCategory
    @ObservedObject var viewModel: SubcategoriesViewModel
    @EnvironmentObject var navigationManager: NavigationManager

    init(category: ServiceCategory, viewModel: SubcategoriesViewModel) {
        self.category = category
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading subcategories...")
                        .padding()
                        .onAppear {
                            print("Loading subcategories for category: \(category.name)")
                        }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .onAppear {
                            print("Error loading subcategories: \(errorMessage)")
                        }
                } else if viewModel.subcategories.isEmpty {
                    Text("No subcategories available.")
                        .padding()
                        .onAppear {
                            print("No subcategories found for category: \(category.name)")
                        }
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.subcategories) { subcategory in
                            Button(action: {
                                print("Navigating to services for subcategory: \(subcategory.name)")
                                navigationManager.navigateTo(subcategory)
                            }) {
                                SubcategoryRow(subcategory: subcategory)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .onAppear {
                        print("Displaying subcategories for category: \(category.name)")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)  // Hide the default back button
        .navigationBarItems(leading: Button(action: {
            print("Back button tapped.")
            navigationManager.goBack()  // Manually call goBack() when custom back button is tapped
        }) {
            Image(systemName: "chevron.left")  // Use the back arrow image for the custom button
                .foregroundColor(.blue)
        })
        .task(id: category.id) {
            print("Fetching subcategories for category: \(category.name)")
            await viewModel.loadSubcategories()
        }
    }
}
