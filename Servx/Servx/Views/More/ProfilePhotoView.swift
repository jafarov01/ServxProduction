//
//  ProfilePhotoView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct ProfilePhotoView: View {
    let imageUrl: URL?
    var placeholderImage: Image = Image(systemName: "person.circle.fill")
    @State private var imageLoadingError: Bool = false
    
    var body: some View {
        Group {
            if let url = imageUrl, !imageLoadingError {
                AsyncImage(url: url) { phase in
                    handleImagePhase(phase)
                }
                .onAppear {
                    printImageDebugInfo(url: url)
                }
            } else {
                placeholderView
            }
        }
    }
    
    @ViewBuilder
    private func handleImagePhase(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .success(let image):
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .onAppear { imageLoadingError = false }
        case .failure(let error):
            placeholderView
                .onAppear {
                    print("🛑 Image load failed: \(error.localizedDescription)")
                    imageLoadingError = true
                }
            Text("Image Load Failed: \(error.localizedDescription)")
        case .empty:
            loadingView
        @unknown default:
            loadingView
        }
    }

    private func printImageDebugInfo(url: URL) {
        print("""
        🖼 Image Debug:
        - Valid URL: \(url.absoluteString)
        - Cache: \(URLCache.shared.cachedResponse(for: URLRequest(url: url)) != nil ? "✅" : "❌")
        - Secure Connection: \(url.scheme?.contains("https") == true ? "✅" : "⚠️ Using HTTP")
        """)
    }

    private var placeholderView: some View {
        placeholderImage
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .foregroundColor(.gray)
    }

    private var loadingView: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
    }
}
