//
//  ProfilePhotoView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ProfilePhotoView: View {
    var height: CGFloat
    var width: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: AuthenticatedUser.shared.profilePhotoUrl ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: width, height: height)
        .background(Color.clear)
        .clipShape(Circle())
    }
}
