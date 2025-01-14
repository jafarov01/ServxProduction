//
//  ServicesView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

struct ServicesView: View {
    @State private var filterInput: String = ""
    var category: ServiceCategory
    var subcategory: ServiceSubcategory
    @EnvironmentObject private var navigationManager: NavigationManager
    //    @ObservedObject private var viewModel: SingleSubCategoryServicesListViewViewModel
    
    init(category: ServiceCategory, subcategory: ServiceSubcategory) {
        self.category = category
        self.subcategory = subcategory
    }
    
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
            
            // Filter Input
            ServxInputView(
                text: $filterInput,
                placeholder: "What's the problem?",
                frameColor: ServxTheme.greyScale400Color,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.blackColor
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Service Provider Posts
            ScrollView {
                VStack(spacing: 16) {
                    //                    ForEach(viewModel.serviceProviderPosts) { post in
                    //                        ServicePostView(
                    //                            postServiceImage: "turanImage", // Replace with actual image if available
                    //                            postServiceName: post.title,
                    //                            postServiceProvider: post.provider,
                    //                            postServiceReviewValue: post.rating,
                    //                            postServiceReviewCount: post.reviews,
                    //                            postServicePrice: post.price,
                    //                            postServiceId: post.id
                    //                        )
                    //                        .padding(.horizontal, 20)
                    //                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle(subcategory.name)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let category = ServxStaticData.serviceCategories[0]
    let subcategory = category.subcategories[0]
    ServicesView(
        category: category,
        subcategory: subcategory
    )
}
