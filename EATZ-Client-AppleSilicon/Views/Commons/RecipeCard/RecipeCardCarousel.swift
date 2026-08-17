//
//  RecipeCardCarousel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import SwiftUI
import Kingfisher

struct RecipeCardCarousel: View {
    let recipes: [RecipeBasic]
    let action: (Int64) -> Void

    private let itemWidth: CGFloat = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 20
    private let itemSpacing: CGFloat = 6
    
    private var itemSize: CGFloat {
        (itemWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: itemSpacing) {
                ForEach(recipes) { recipe in
                    RecipeCard(imageUrl: recipe.imageUrl ?? "", size: itemSize) { action(recipe.id) }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 10)
        }
    }
}
