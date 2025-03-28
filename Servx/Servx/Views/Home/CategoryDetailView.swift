//
//  sex.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

import SwiftUI

struct CategoryDetailView: View {
    let category: ServiceCategory
    @EnvironmentObject private var navManager: NavigationManager
    @StateObject private var viewModel: CategoryDetailViewModel
    
    init(category: ServiceCategory) {
        self.category = category
        self._viewModel = StateObject(
            wrappedValue: CategoryDetailViewModel(category: category)
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.serviceAreas) { area in
                    NavigationRow(title: area.name) {
                        navManager.navigateToServiceArea(area)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.name)
        .task { await viewModel.fetchServiceAreas() }
    }
}
