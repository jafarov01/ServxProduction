//
//  SupportView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import SwiftUI

struct SupportView: View {
    @StateObject private var viewModel = SupportViewModel()
    @EnvironmentObject private var navigator: NavigationManager
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {

                 Text("Contact Support").font(.title).padding(.bottom)
                 Text("Please describe the issue you are experiencing:").font(.subheadline).foregroundColor(.gray)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.supportMessage)
                        .frame(height: 200)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 1)
                        )
                        .focused($isTextEditorFocused)

                    if viewModel.supportMessage.isEmpty {
                        Text("Type your message here...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 8 + 5)
                            .padding(.vertical, 8 + 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.bottom)

                if let successMsg = viewModel.successMessage {
                    Text(successMsg)
                        .font(.footnote)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMsg = viewModel.errorMessage {
                    Text(errorMsg)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }


                Button {
                    isTextEditorFocused = false
                    Task { await viewModel.sendRequest() }
                } label: {
                    Text("Send Support Request")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1.0 : 0.6)


                Spacer()

            }
            .padding()
             .onTapGesture {
                 isTextEditorFocused = false
             }


            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Sending...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(30)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}
