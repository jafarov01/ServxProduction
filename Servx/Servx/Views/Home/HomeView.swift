//////
//////  HomeView.swift
//////  Servx
//////
//////  Created by Makhlug Jafarov on 18/07/2024.
//////
/////
//import SwiftUI
//
//struct HomeView: View {
//    @State private var searchInput: String = ""
//    @ObservedObject var viewModel = HomeViewModel()
//    @EnvironmentObject private var navigationManager: NavigationManager
//    
//    
//    private let itemsPerRow = 4
//    
//    var body: some View {
//        HStack {
//            Button(action: {
//                navigationManager.goBack()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.blue)
//                    .padding()
//            }
//            .padding(.leading, 10)
//            
//            Spacer()
//        }
//        .frame(height: 44)
//        ScrollView {
//            VStack(spacing: 24) {
//                // Header with Profile and Actions
//                headerSection
//                
//                // Search Input
//                ServxInputView(
//                    text: $searchInput,
//                    placeholder: "Search for services",
//                    frameColor: ServxTheme.blackColor,
//                    backgroundColor: ServxTheme.blackColor,
//                    textColor: ServxTheme.blackColor
//                )
//                .padding(.horizontal, 20)
//                
//                // Horizontal Cards
//                horizontalScrollSection
//                
//                // Categories Section
//                categoriesSection
//                
//                // Recommended Services
//                recommendedServicesSection
//            }
//            .padding(.vertical, 20)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//extension HomeView {
//    // MARK: - Header Section
//    private var headerSection: some View {
//        HStack {
//            // Profile Photo
//            //            ProfilePhotoView(
//            //                viewModel: viewModel.profilePhotoViewModel,
//            //                width: 48,
//            //                height: 48
//            //            )
//            
//            // Greeting and Username
//            VStack(alignment: .leading, spacing: 4) {
//                ServxTextView(
//                    text: "Good Morning 👋🏻",
//                    color: ServxTheme.blackColor,
//                    size: 14,
//                    weight: .regular
//                )
//                
//                ServxTextView(
//                    text: "test user full name",
//                    color: ServxTheme.primaryColor,
//                    size: 18,
//                    weight: .bold
//                )
//            }
//            
//            Spacer()
//            
//            // Notification and Bookmark Icons
//            //            HStack(spacing: 16) {
//            //                Image("notificationIcon")
//            //                    .resizable()
//            //                    .frame(width: 28, height: 28)
//            //
//            //                Image("bookmarkIcon")
//            //                    .resizable()
//            //                    .frame(width: 28, height: 28)
//            //            }
//        }
//        .padding(.horizontal, 20)
//    }
//    
//    // MARK: - Horizontal Scroll Section
//    private var horizontalScrollSection: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                ForEach(0..<10) { index in
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(ServxTheme.primaryColor)
//                        .frame(width: 280, height: 134)
//                        .overlay(
//                            Text("This is the \(index)th page here")
//                                .foregroundColor(.white)
//                        )
//                }
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//    
//    // MARK: - Categories Section
//    private var categoriesSection: some View {
//        VStack(spacing: 16) {
//            sectionHeader(
//                title: "Category",
//                actionTitle: "View all"
//            )
//            
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: itemsPerRow), spacing: 16) {
//                ForEach(ServxStaticData.serviceCategories, id: \.name) { category in
//                    Button(action: {
//                        print("touched ", category.name)
//                        navigationManager.navigate(to: .subcategories(category: category))
//                    }) {
//                        CategoryButton(categoryName: category.name)
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//        .environmentObject(navigationManager)
//    }
//    
//    // MARK: - Recommended Services Section
//    private var recommendedServicesSection: some View {
//        VStack(spacing: 16) {
//            // Title
//            sectionHeader(
//                title: "Recommended Services",
//                actionTitle: "View all"
//            )
//            
//            // Recommended Service Posts Placeholder
//            VStack(spacing: 12) {
//                // Uncomment and implement when data is available
//                // ForEach(viewModel.recommendedServiceProviderPosts) { post in
//                //     ServicePostView(
//                //         postServiceImage: "serviceImage",
//                //         postServiceName: post.title,
//                //         postServiceProvider: post.serviceProvider,
//                //         postServiceReviewValue: post.rating,
//                //         postServiceReviewCount: post.reviews,
//                //         postServicePrice: post.price,
//                //         postServiceId: post.id
//                //     )
//                // }
//                Text("No recommended services available")
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.horizontal, 20)
//    }
//    
//    // MARK: - Section Header Helper
//    private func sectionHeader(title: String, actionTitle: String) -> some View {
//        HStack {
//            ServxTextView(
//                text: title,
//                color: ServxTheme.blackColor,
//                size: 18,
//                weight: .bold
//            )
//            
//            Spacer()
//            
//            ServxTextView(
//                text: actionTitle,
//                color: ServxTheme.primaryColor,
//                size: 14,
//                weight: .regular
//            )
//            .onTapGesture {
//                // Handle action tap here
//            }
//        }
//    }
//}
//
//#Preview {
//    let navigationManager = NavigationManager()
//    HomeView()
//        .environmentObject(navigationManager) // Provide the environment object for the preview
//}
