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
    var categories: [CategoryListItem]
    var title: String
    var onCardTapped: (() -> Void)? = nil
    var onLikeTapped: (() -> Void)? = nil
    var onBookmarkTapped: (() -> Void)? = nil
    
    var body: some View {
        if onCardTapped != nil {
            VStack(spacing: 10) {
                RecipeCardView(image: image, categories: categories, title: title)
                InteractionBar(onLikeTapped: onLikeTapped, onBookmarkTapped: onBookmarkTapped)
            }
            .onTapGesture {
                onCardTapped?()
            }
        } else {
            VStack(spacing: 10) {
                RecipeCardView(image: image, categories: categories, title: title)
                InteractionBar(onLikeTapped: onLikeTapped, onBookmarkTapped: onBookmarkTapped)
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
            CategoryListItem(id: 1, name: "불닭 소스"),
            CategoryListItem(id: 2, name: "매콤"),
            CategoryListItem(id: 3, name: "황금 레시피")
        ],
        title: "간단한 닭 요리, 치즈불닭 황금 레시피"
    )
}
