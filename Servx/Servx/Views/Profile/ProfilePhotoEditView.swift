//
//  ProfilePhotoEditView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import SwiftUI
import UIKit

struct ProfilePhotoEditView: View {
    @StateObject private var viewModel: ProfilePhotoEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    
    init(viewModel: ProfilePhotoEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                ProfilePhotoView(imageUrl: URL(string: AuthenticatedUser.shared.profilePhotoUrl ?? ""))
                    .frame(width: 140, height: 140)
            }

            // Buttons for selecting photo source
            HStack {
                Button("Take Photo") {
                    showImagePicker = true
                }
                .padding()

                Button("Choose from Library") {
                    showImagePicker = true
                }
                .padding()
            }

            // Remove photo button
            if selectedImage != nil {
                Button("Remove Photo") {
                    Task {
                        await viewModel.removeProfilePhoto()
                    }
                }
                .padding()
            }

            if viewModel.isLoading {
                ProgressView("Updating photo...")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }

            Button("Save") {
                if let selectedImage = selectedImage {
                    Task {
                        await viewModel.selectNewPhoto(selectedImage)
                    }
                }
            }
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .navigationTitle("Edit Profile Photo")
    }
}
