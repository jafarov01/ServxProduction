//
//  SubcategoriesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct SubcategoriesListView: View {
    let category: ServiceCategory

    @EnvironmentObject private var navigator: NavigationManager

    @StateObject private var viewModel: SubcategoriesViewModel

    init(category: ServiceCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: SubcategoriesViewModel(category: category))
        print("SubcategoriesListView initialized for category: \(category.name)") // Added print for debug
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                navigationHeader
                contentState
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            if viewModel.subcategories.isEmpty {
                await viewModel.loadSubcategories()
            }
        }
    }
    
    private var navigationHeader: some View {
        HStack {
            Button(action: navigator.goBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var contentState: some View {
        if viewModel.isLoading {
            ProgressView("Loading subcategories...")
                .padding()
        } else if let error = viewModel.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .padding()
        } else if viewModel.subcategories.isEmpty {
            Text("No subcategories available.")
                .padding()
        } else {
            subcategoriesGrid
        }
    }
    
    private var subcategoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
            ForEach(viewModel.subcategories) { subcategory in
                Button {
                    navigator.navigate(to: AppRoute.Main.subcategory(subcategory))
                } label: {
                    SubcategoryRow(subcategory: subcategory)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
