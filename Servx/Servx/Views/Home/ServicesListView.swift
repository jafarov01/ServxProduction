//
//  ServicesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ServicesListView: View {
    let subcategory: ServiceArea
    @StateObject private var viewModel: ServicesViewModel
    @EnvironmentObject private var navigator: NavigationManager

    init(subcategory: ServiceArea) {
        self.subcategory = subcategory
        _viewModel = StateObject(wrappedValue: ServicesViewModel(subcategory: subcategory))
        print("ServicesListView initialized for subcategory: \(subcategory.name)")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                navigationHeader
                contentState
            }
            .padding(.vertical)
        }
        .navigationTitle(subcategory.name)
        .navigationBarBackButtonHidden()
        .task {
            if viewModel.services.isEmpty {
                await viewModel.loadServices()
            }
        }
        .alert(item: $viewModel.errorWrapper) { wrapper in
            Alert(
                title: Text("Error"),
                message: Text(wrapper.message), // Use message from the wrapper
                dismissButton: .default(Text("OK"))
            )
        }
    }

     @ViewBuilder
     private var contentState: some View {
         if viewModel.isLoading {
             ProgressView("Loading...")
                 .padding(.top, 40)
         } else if viewModel.errorWrapper != nil {
              errorStatePlaceholder
         } else if viewModel.filteredServices.isEmpty && !viewModel.searchQuery.isEmpty {
             noSearchResultsState
         } else if viewModel.services.isEmpty {
             emptyState
         } else {
             servicesList
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
     
     private var errorStatePlaceholder: some View {
         VStack {
             Image(systemName: "exclamationmark.triangle")
                 .font(.largeTitle)
                 .foregroundColor(.orange)
                 .padding()
             Text("Could not load services.")
                 .foregroundColor(.secondary)
             Button("Retry") {
                 Task { await viewModel.loadServices() }
             }
             .padding(.top)
         }
         .padding()
     }

    private var emptyState: some View {
        VStack {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .padding()

            Text("No services found for \(subcategory.name)")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
    
    private var noSearchResultsState: some View {
         VStack {
             Image(systemName: "magnifyingglass")
                 .font(.largeTitle)
                 .foregroundColor(.gray)
                 .padding()
             Text("No services found matching '\(viewModel.searchQuery)'")
                 .multilineTextAlignment(.center)
                 .foregroundColor(.gray)
         }
         .padding(.top, 40)
     }


    private var servicesList: some View {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredServices) { service in
                    Button {
                         print("Navigating to service request for: \(service.providerName)")
                         navigator.navigate(to: AppRoute.Main.serviceProfileDetail(service))
                    } label: {
                         ServiceDetailedCard(service: service)
                             .padding(.horizontal, 20)
                    }
                     .buttonStyle(PlainButtonStyle())
                }
            }
            .transition(.opacity)
    }
}
