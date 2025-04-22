//
//  SupportView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import SwiftUI

struct SupportView: View {
    // Create and own the ViewModel for this view's lifecycle
    @StateObject private var viewModel = SupportViewModel()
    // Access navigator if needed for custom back button or other navigation
    @EnvironmentObject private var navigator: NavigationManager
    // Focus state for the text editor
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        ZStack { // Use ZStack for overlaying loading indicator
            VStack(alignment: .leading, spacing: 16) { // Main content stack

                 Text("Contact Support").font(.title).padding(.bottom)
                 Text("Please describe the issue you are experiencing:").font(.subheadline).foregroundColor(.gray)

                // Text Editor for the message
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.supportMessage)
                        .frame(height: 200) // Suggest a reasonable height
                        .padding(8) // Padding inside the border
                        .background(Color(.systemBackground)) // Use system background or theme
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 1) // Use theme border
                        )
                        .focused($isTextEditorFocused) // Manage focus state

                    // Placeholder text overlay
                    if viewModel.supportMessage.isEmpty {
                        Text("Type your message here...")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.horizontal, 8 + 5) // Match TextEditor internal padding
                            .padding(.vertical, 8 + 8)
                            .allowsHitTesting(false) // Let taps pass through to TextEditor
                    }
                }
                .padding(.bottom) // Space below text editor

                // Display Success or Error Messages
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
                        .multilineTextAlignment(.center) // Allow multi-line errors
                }


                // Send Button (Using standard SwiftUI Button)
                Button {
                    isTextEditorFocused = false // Dismiss keyboard
                    Task { await viewModel.sendRequest() }
                } label: {
                    Text("Send Support Request")
                        .frame(maxWidth: .infinity) // Make label fill width
                        .frame(height: 44) // Standard button height
                }
                .buttonStyle(.borderedProminent) // Use prominent style for primary action
                .tint(ServxTheme.primaryColor) // Use theme color
                // Disable button based on ViewModel state
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1.0 : 0.6) // Visual cue for disabled state


                Spacer() // Push content to top

            } //: VStack
            .padding() // Padding around the main content
            // Hide keyboard when tapping outside TextEditor
             .onTapGesture {
                 isTextEditorFocused = false
             }


            // --- Loading Indicator Overlay ---
            if viewModel.isLoading {
                Color.black.opacity(0.4) // Semi-transparent background
                    .ignoresSafeArea()
                ProgressView("Sending...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(30)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

        } //: ZStack
        .navigationTitle("Support") // Set title for the navigation bar
        .navigationBarTitleDisplayMode(.inline)
        // Optional: Add .toolbar if you need custom bar buttons
    }
}
