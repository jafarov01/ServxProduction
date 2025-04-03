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
    @EnvironmentObject var navigationManager: NavigationManager // new

    init(category: ServiceCategory, viewModel: SubcategoriesViewModel) {
        self.category = category
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading subcategories...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.subcategories) { subcategory in
                            Button(action: {
                                navigationManager.navigate( // new
                                    to: .services(subcategory: subcategory))
                            }) {
                                SubcategoryRow(subcategory: subcategory)
                            }
                        }
                        
                        
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .task(id: category.id) {
            await viewModel.loadSubcategories()
        }
    }
}
