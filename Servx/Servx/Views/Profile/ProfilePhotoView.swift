//
//  ProfilePhotoView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ProfilePhotoView: View {
    var imageUrl: URL?
    var placeholderImage: Image = Image(systemName: "person.circle.fill")

    var body: some View {
        if let url = imageUrl {
            // Use AsyncImage to load the image from URL
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else if phase.error != nil {
                    placeholderImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                } else {
                    // While loading, show a gray circle placeholder
                    Circle().fill(Color.gray.opacity(0.3))
                }
            }
        } else {
            // If the URL is nil, show a placeholder image
            placeholderImage
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .foregroundColor(.gray)
        }
    }
}
