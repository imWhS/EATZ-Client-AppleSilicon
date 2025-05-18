//
//  RecipeListItemView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/11/25.
//

import SwiftUI
import Kingfisher

struct RecipeListItemView: View {
    
    var image: String
    var categories: [CategoryBasic]
    var title: String
    var onLikeTapped: (() -> Void)? = nil
    var onBookmarkTapped: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            RecipeCardView(image: image, categories: categories, title: title)
            InteractionBar(onLikeTapped: onLikeTapped, onBookmarkTapped: onBookmarkTapped)
        }
    }
    
    struct RecipeCardView: View {
        var image: String
        var categories: [CategoryBasic]
        var title: String

        @State private var isPressed = false
        @State private var imageHeight: CGFloat = .zero

        var body: some View {
            VStack(spacing: 2) {
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

                Header(image: image, categories: categories, title: title)
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
    }
    
    struct Header: View {
        var image: String
        var categories: [CategoryBasic]
        var title: String

        var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Text("# \(category.name)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.init("BEBEB9"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.black)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
        }
    }
    
    struct InteractionBar: View {
        var onLikeTapped: (() -> Void)? = nil
        var onBookmarkTapped: (() -> Void)? = nil
        
        var body: some View {
            HStack {
                HStack(spacing: 12) {
                    SubInfoItemView(icon: "recipe-list-item-rating", texts: [
                                        ("3.6", .bold),
                                        ("(12)", .medium)
                                    ])
                    SubInfoItemView(icon: "recipe-list-item-time", texts: [
                        ("10분", .bold)
                    ])
                }
                .padding(3)
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                       onLikeTapped?()
                    }) {
                       Image("recipe-list-item-like")
                    }
                    Button(action: {
                       onBookmarkTapped?()
                    }) {
                       Image("recipe-list-item-save")
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    struct SubInfoItemView: View {
        let icon: String
        let texts: [(String, Font.Weight)]

        var body: some View {
            HStack(spacing: 2) {
                Image(icon)
                ForEach(Array(texts.enumerated()), id: \.offset) { _, item in
                    Text(item.0)
                        .font(.system(size: 12, weight: item.1))
                        .foregroundStyle(Color("A1A1A1"))
                }
            }
        }
    }
    
}

#Preview {
    RecipeListItemView(
        image: "sampleRecipeImage",
        categories: [
            CategoryBasic(id: 1, name: "불닭 소스"),
            CategoryBasic(id: 2, name: "매콤"),
            CategoryBasic(id: 3, name: "황금 레시피")
        ],
        title: "간단한 닭 요리, 치즈불닭 황금 레시피"
    )
}
