//
//  TestView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import SwiftUI

struct TestView: View {
    @StateObject private var viewModel = TestViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Button to fetch categories
                Button(action: {
                    Task {
                        await viewModel.fetchCategories()
                    }
                }) {
                    Text("Fetch Categories")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                // Button to fetch areas
                Button(action: {
                    Task {
                        await viewModel.fetchAreas()
                    }
                }) {
                    Text("Fetch Areas")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()

                // Display categories
                if !viewModel.serviceCategories.isEmpty {
                    Text("Service Categories:")
                        .font(.headline)
                        .padding(.top)
                    List(viewModel.serviceCategories, id: \.id) { category in
                        Text(category.name)
                    }
                    .frame(height: 200) // Limit height
                }

                // Display areas
                if !viewModel.serviceAreas.isEmpty {
                    Text("Service Areas:")
                        .font(.headline)
                        .padding(.top)
                    List(viewModel.serviceAreas, id: \.id) { area in
                        Text(area.name)
                    }
                    .frame(height: 200) // Limit height
                }
            }
            .navigationTitle("API Test View")
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
