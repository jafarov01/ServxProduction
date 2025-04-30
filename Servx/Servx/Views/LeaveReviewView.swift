//
//  LeaveReviewView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//

import SwiftUI

// MARK: - Leave Review View
struct LeaveReviewView: View {
    @StateObject private var viewModel: LeaveReviewViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFocused: Bool
    @EnvironmentObject private var navigator: NavigationManager

    init(bookingId: Int64, providerName: String, serviceName: String) {
        _viewModel = StateObject(
            wrappedValue: LeaveReviewViewModel(
                bookingId: bookingId,
                providerName: providerName,
                serviceName: serviceName
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    navigator.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(ServxTheme.primaryColor)
                        .padding()
                }
                // Context Text
                Text(
                    "Leave a review for \(viewModel.providerName)'s \(viewModel.serviceName) service"
                )
                .font(.headline)
                .padding(.bottom, 10)

                // Star Rating Section
                VStack(alignment: .center) {
                    Text("Your Rating")
                        .font(.title3)
                    starRatingInput(rating: $viewModel.rating)
                }
                .frame(maxWidth: .infinity)

                // Comment Section
                VStack(alignment: .leading) {
                    Text("Add a Comment (Optional)")
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.comment)
                            .frame(height: 150)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color.gray.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                            .focused($isCommentFocused)

                        if viewModel.comment.isEmpty {
                            Text("Share your experience...")
                                .foregroundColor(
                                    Color(UIColor.placeholderText)
                                )
                                .padding(.horizontal, 8 + 5)
                                .padding(.vertical, 8 + 8)
                                .allowsHitTesting(false)
                        }
                    }
                }

                // Error Message Display
                if let errorMsg = viewModel.errorMessage {
                    Text(errorMsg)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let successMsg = viewModel.successMessage {
                    Text(successMsg)
                        .font(.footnote)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Spacer(minLength: 20)

                // Submit Button
                Button {
                    isCommentFocused = false
                    Task { await viewModel.submitReview() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        }
                        Text(
                            viewModel.isLoading
                                ? "Submitting..." : "Submit Review"
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)
                .disabled(!viewModel.canSubmit)
                .opacity(!viewModel.canSubmit ? 0.6 : 1.0)

            }
            .padding()

        }
        .background(ServxTheme.backgroundColor)
        .navigationTitle("Leave a Review")
        .navigationBarTitleDisplayMode(.inline)
        // Dismiss view on successful submission
        .onChange(of: viewModel.didSubmitSuccessfully) { _, submitted in
            if submitted {
                print("LeaveReviewView: Submission successful, dismissing.")

                dismiss()
            }
        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            isCommentFocused = false
        }
    }

    @ViewBuilder
    private func starRatingInput(rating: Binding<Double>) -> some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { number in
                Image(
                    systemName: number > Int(rating.wrappedValue.rounded(.up))
                        ? "star" : "star.fill"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(
                    number > Int(rating.wrappedValue.rounded(.up))
                        ? Color.gray.opacity(0.5) : Color.yellow
                )
                .onTapGesture {
                    rating.wrappedValue = Double(number)
                }
            }
        }
    }
}
