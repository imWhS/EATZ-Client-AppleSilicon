//
//  RecipeCardView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI
import Kingfisher

struct RecipeCardView: View {
    var image: String
    var categories: [CategoryListItem]
    var title: String

    @State private var isPressed = false
    @State private var imageHeight: CGFloat = .zero

    var body: some View {
        VStack(spacing: 2) {
            recipeImage
            RecipeCardViewHeader(image: image, categories: categories, title: title)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(20)
        .clipped()
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 2)
        .padding(.horizontal, 20)
        .scaleEffect(isPressed ? 0.975 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    var recipeImage: some View {
        KFImage(URL(string: image))
            .placeholder { ProgressView() }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: imageHeight)
            .clipped()
            .cornerRadius(16)
            .onReadSize { size in
                imageHeight = size.width * 2/3
            }
    }
}

//#Preview {
//    RecipeCardView()
//}
