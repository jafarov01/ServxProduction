//
//  ServiceProfileDetailsView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//


import SwiftUI

// MARK: - Service Profile Details View
struct ServiceProfileDetailsView: View {
    @StateObject private var viewModel: ServiceProfileDetailsViewModel
    @EnvironmentObject private var navigator: NavigationManager

    init(serviceProfile: ServiceProfile) {
        _viewModel = StateObject(wrappedValue: ServiceProfileDetailsViewModel(
            serviceProfile: serviceProfile
        ))
        print("✅ ServiceProfileDetailsView initialized for service: \(serviceProfile.serviceTitle), ID: \(serviceProfile.id)")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // --- Profile Header ---
                profileHeaderSection(profile: viewModel.serviceProfile)

                // --- Service Details (Price, Experience) ---
                serviceDetailsSection(profile: viewModel.serviceProfile)

                // --- Reviews Section ---
                reviewsSection()

                Spacer()

            }
            .padding(.bottom, 80)

        }
        .background(ServxTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle(viewModel.serviceProfile.serviceTitle)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
             requestServiceButton()
                 .padding(.horizontal)
                 .padding(.bottom, 10)
                 .background(.thinMaterial)
         }
        .task {
             await viewModel.fetchReviews(initialLoad: true)
        }
         .alert("Error Loading Reviews", isPresented: Binding(
             get: { viewModel.reviewsErrorMessage != nil },
             set: { _,_ in viewModel.reviewsErrorMessage = nil }
         )) {
             Button("OK") {}
         } message: {
             Text(viewModel.reviewsErrorMessage ?? "Could not load reviews.")
         }
    }

    // MARK: - Subviews

    // Profile Header (Photo, Name, Rating)
    @ViewBuilder
    private func profileHeaderSection(profile: ServiceProfile) -> some View {
        HStack(spacing: 15) {
             ProfilePhotoView(imageUrl: URL(string: profile.profilePhotoUrl ?? ""))
                 .frame(width: 70, height: 70)
                 .clipShape(Circle())

             VStack(alignment: .leading, spacing: 4) {
                 Text(profile.providerName)
                     .font(.title2)
                     .fontWeight(.bold)
                     .foregroundColor(ServxTheme.primaryColor)

                 HStack(spacing: 4) {
                     Image(systemName: "star.fill")
                         .foregroundColor(.orange)
                     Text("\(profile.rating, specifier: "%.1f")")
                         .fontWeight(.semibold)
                     Text("(\(profile.reviewCount) reviews)")
                         .foregroundColor(ServxTheme.secondaryTextColor)
                 }
                 .font(.subheadline)
             }
             Spacer()
         }
         .padding(.horizontal)
         .padding(.top)
    }

    // Service Details (Experience, Price)
    @ViewBuilder
    private func serviceDetailsSection(profile: ServiceProfile) -> some View {
         VStack(alignment: .leading, spacing: 8) {
             Text("Details")
                 .font(.title3.weight(.semibold))
                 .padding(.horizontal)

             detailRow(label: "Category:", value: profile.categoryName)
             detailRow(label: "Service:", value: profile.serviceTitle)
             detailRow(label: "Experience:", value: profile.workExperience)
             detailRow(label: "Base Price:", value: String(format: "$%.2f", profile.price))

         }
         .padding(.bottom)
     }

    // Reviews List Section
    @ViewBuilder
    private func reviewsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reviews")
                .font(.title3.weight(.semibold))
                .padding(.horizontal)

            if viewModel.isLoadingReviews && viewModel.reviews.isEmpty {
                 ProgressView()
                     .frame(maxWidth: .infinity)
                     .padding(.vertical)
             } else if viewModel.reviews.isEmpty && viewModel.reviewsErrorMessage == nil {
                 Text("No reviews yet.")
                     .foregroundColor(ServxTheme.secondaryTextColor)
                     .frame(maxWidth: .infinity)
                     .padding()
             } else {
                 // Display fetched reviews
                  LazyVStack(alignment: .leading, spacing: 0) {
                      ForEach(viewModel.reviews) { review in
                          ReviewRowView(review: review)
                              .padding(.horizontal)
                          Divider().padding(.horizontal)
                              .onAppear {
                                  // Pagination trigger
                                  if review.id == viewModel.reviews.last?.id && viewModel.canLoadMoreReviews && !viewModel.isLoadingReviews {
                                      Task { await viewModel.loadMoreReviews() }
                                  }
                              }
                      }
                      // Loading indicator for pagination
                      if viewModel.isLoadingReviews && !viewModel.reviews.isEmpty {
                          ProgressView().padding().frame(maxWidth: .infinity)
                      }
                 }
             }
             if let errorMsg = viewModel.reviewsErrorMessage {
                  Text("⚠️ \(errorMsg)")
                      .foregroundColor(.red)
                      .font(.caption)
                      .frame(maxWidth: .infinity)
                      .padding()
              }
        }
    }

    // Helper for detail rows
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
         HStack {
             Text(label)
                 .font(.callout)
                 .foregroundColor(ServxTheme.secondaryTextColor)
                 .frame(width: 100, alignment: .leading)
             Text(value)
                  .font(.callout.weight(.medium))
                  .foregroundColor(ServxTheme.primaryColor)
             Spacer()
         }
         .padding(.horizontal)
     }
    
    // Request Service Button (at the bottom)
     @ViewBuilder
     private func requestServiceButton() -> some View {
         Button {
              print("Navigating to Request Service for \(viewModel.serviceProfile.serviceTitle)")
              navigator.navigate(to: AppRoute.Main.serviceRequest(viewModel.serviceProfile))
          } label: {
              Text("Request for Service")
                  .frame(maxWidth: .infinity)
                  .frame(height: 44)
          }
          .buttonStyle(.borderedProminent)
          .tint(ServxTheme.primaryColor)
     }
}

import SwiftUI

// MARK: - View for Displaying a Single Review
struct ReviewRowView: View {
    let review: ReviewDTO

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Reviewer's Photo
            ProfilePhotoView(imageUrl: review.reviewerPhotoURLObject)
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            // Reviewer Name, Rating, Comment, Date
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(review.reviewerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ServxTheme.primaryColor)
                    Spacer()
                    Text(review.createdAtDate?.formatted(.relative(presentation: .named)) ?? "-")
                        .font(.caption)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                }

                // Static Star Rating Display
                StaticStarRatingView(rating: review.rating)

                // Comment
                if let comment = review.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.body)
                        .foregroundColor(ServxTheme.primaryColor)
                        .lineLimit(nil)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helper View for Static Star Display
struct StaticStarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    let starColor: Color = .orange
    let size: CGFloat = 14

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: starIconName(for: star))
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(starColor)
                    .frame(width: size, height: size)
            }
        }
    }

    private func starIconName(for star: Int) -> String {
        let ratingValue = rating
        if ratingValue >= Double(star) {
            return "star.fill"
        } else if ratingValue >= Double(star) - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
