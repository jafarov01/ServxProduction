//
//  ProfilePhotoEditView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfilePhotoEditView: View {
    @EnvironmentObject private var navigator: NavigationManager
    @StateObject private var photoEditVM = ProfilePhotoEditViewModel()
    @StateObject private var photoVM = ProfilePhotoViewModel()
    @State private var selectedImage: UIImage?
    
    private enum PhotoSource: Identifiable {
        case camera, library
        var id: Self { self }
    }
    
    @State private var selectedSource: PhotoSource?

    var body: some View {
        VStack(spacing: 24) {
            navigationHeader
            photoPreview
            actionButtons
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
            guard let image = newValue else { return }
            Task { await photoEditVM.savePhoto(image) }
        }
        .onChange(of: photoEditVM.isLoading) { _, newValue in
            if !newValue { navigator.goBack() }
        }
        .navigationBarHidden(true)
        .debugRender("ProfilePhotoEditView")
    }
    
    private var navigationHeader: some View {
        HStack {
            Button(action: { navigator.goBack() }) {
                Image(systemName: "xmark")
                    .foregroundColor(ServxTheme.primaryColor)
            }
            Spacer()
            ServxTextView(
                text: "Edit Profile Photo",
                color: ServxTheme.primaryColor,
                size: 20,
                weight: .bold
            )
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var photoPreview: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                ProfilePhotoView(imageUrl: AuthenticatedUser.shared.currentUser?.profilePhotoUrl)
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
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
            
            if photoVM.user?.profilePhotoUrl != nil {
                ServxButtonView(
                    title: "Remove Photo",
                    width: 200,
                    height: 44,
                    frameColor: .red,
                    innerColor: .red,
                    textColor: .white,
                    action: { Task { await photoEditVM.removePhoto() } }
                )
            }
        }
    }
}
