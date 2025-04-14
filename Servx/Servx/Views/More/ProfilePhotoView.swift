//
//  ProfilePhotoView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfilePhotoView: View {
    let imageUrl: URL?
    let placeholder = Image(systemName: "person.circle.fill")
    
    private var cacheBustedUrl: URL? {
        guard let imageUrl else { return nil }
        let bustedUrl = imageUrl.appending(queryItems: [
            URLQueryItem(name: "t", value: UUID().uuidString)
        ])
        viewLogger.debug("issue01: cacheBustedUrl used in AsyncImage: \(bustedUrl.absoluteString)")
        return bustedUrl
    }

    var body: some View {
        if let url = cacheBustedUrl {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())

                case .failure:
                    placeholderView

                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        placeholder
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray.opacity(0.4))
            .clipShape(Circle())
    }
}
