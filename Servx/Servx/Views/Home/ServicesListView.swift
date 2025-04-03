//
//  ServicesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ServicesListView: View {
    let subcategory: Subcategory
    @ObservedObject var viewModel: ServicesViewModel

    // Dependency Injection for ViewModel
    init(subcategory: Subcategory, viewModel: ServicesViewModel) {
        self.subcategory = subcategory
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ServxInputView(
                    text: $viewModel.searchQuery,
                    placeholder: "What's the problem?",
                    frameColor: Color("greyscale400Color"),
                    backgroundColor: Color("greyscale100Color"),
                    textColor: Color("greyscale900Color")
                )
                .padding(.horizontal, 20)
                
                if viewModel.isLoading {
                    ProgressView("Loading services...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.filteredServices) { service in
                            ServiceDetailedCard(service: service)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .task(id: subcategory.id) {
            await viewModel.loadServices()
        }
    }
}
