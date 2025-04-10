//
//  ProfilePhotoEditView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfilePhotoEditView: View {
    @EnvironmentObject private var editViewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoViewModel = ProfilePhotoEditViewModel()
    @State private var selectedImage: UIImage?

    private enum PhotoSource: Identifiable {
        case camera
        case library

        var id: Int {
            switch self {
            case .camera: return 0
            case .library: return 1
            }
        }
    }

    @State private var selectedSource: PhotoSource?

    var body: some View {
        VStack(spacing: 24) {
            ServxTextView(
                text: "Edit Profile Photo",
                color: ServxTheme.primaryColor,
                size: 20,
                weight: .bold
            )

            photoPreview

            VStack(spacing: 16) {
                photoActionButtons
                removePhotoButton
            }

            Spacer()
        }
        .padding()
        .sheet(item: $selectedSource) { source in
            PhotoPicker(
                selectedImage: $selectedImage,
                sourceType: source == .camera ? .camera : .photoLibrary
            )
        }
        .onChange(of: selectedImage) { _, newValue in
            handleImageSelection(newValue)
        }
    }

    // MARK: - Subviews

    private var photoPreview: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                ProfilePhotoView(imageUrl: editViewModel.user?.profilePhotoUrl)
                    .frame(width: 200, height: 200)
            }
        }
    }

    private var photoActionButtons: some View {
        Group {
            ServxButtonView(
                title: "Take Photo",
                width: 200,
                height: 44,
                frameColor: ServxTheme.primaryColor,
                innerColor: ServxTheme.primaryColor,
                textColor: .white,
                action: { selectedSource = .camera }
            )

            ServxButtonView(
                title: "Choose from Library",
                width: 200,
                height: 44,
                frameColor: ServxTheme.primaryColor,
                innerColor: ServxTheme.primaryColor,
                textColor: .white,
                action: { selectedSource = .library }
            )
        }
    }

    private var removePhotoButton: some View {
        Group {
            if editViewModel.user?.profilePhotoUrl != nil {
                ServxButtonView(
                    title: "Remove Photo",
                    width: 200,
                    height: 44,
                    frameColor: .red,
                    innerColor: .red,
                    textColor: .white,
                    action: removePhoto
                )
            }
        }
    }

    // MARK: - Actions

    private func handleImageSelection(_ image: UIImage?) {
        guard let image else { return }
        Task {
            await photoViewModel.savePhoto(image)
            await editViewModel.loadUser()
        }
    }

    private func removePhoto() {
        Task {
            await photoViewModel.removePhoto()
            await editViewModel.loadUser()
            dismiss()
        }
    }
}
