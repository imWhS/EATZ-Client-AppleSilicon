//
//  RecipeBasicItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/20/25.
//

import SwiftUI
import Kingfisher

struct RecipeBasicItem<MenuContent: View>: View {
    let recipe: RecipeBasic
    var onRecipeTapped: (RecipeBasic) -> Void
    @ViewBuilder let menuContent: ((RecipeBasic) -> MenuContent)?
    
    init(
        recipe: RecipeBasic,
        onRecipeTapped: @escaping (RecipeBasic) -> Void,
        menuContent: ((RecipeBasic) -> MenuContent)? = nil
    ) {
        self.recipe = recipe
        self.onRecipeTapped = onRecipeTapped
        self.menuContent = menuContent
    }
    
    private var totalTimeLabel: String {
        let totalTime = (recipe.cookingTime ?? 0) + (recipe.prepTime ?? 0)
        return "\(totalTime)분"
    }
    
    var body: some View {
        VStack {
            Button(action: { onRecipeTapped(recipe) }) {
                HStack(spacing: 0) {
                    imageView
                    detailView
                }
                .clipped()
                .background(Color.white)
                .cornerRadius(16)
            }
            .buttonStyle(ListItemButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    private var imageView: some View {
        KFImage(URL(imageUrlString: recipe.imageUrl))
            .placeholder {
                VStack {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.buttonSecondary)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 96, height: 96)
            .clipped()
    }
    
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(recipe.title)
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(2)
                .padding(.horizontal, 14)
            Spacer()
            detailBottomView()
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func detailBottomView() -> some View {
        HStack(alignment: .center, spacing: 4) {
            RecipeItemEssentialInfoView(
                cookingTime: recipe.cookingTime,
                prepTime: recipe.prepTime,
                ratingAverageScore: recipe.ratingAverageScore,
                ratingCount: recipe.ratingCount,
                axis: .horizontal
            )
            Spacer()
            if let menuContent = menuContent {
                Menu {
                    menuContent(recipe)
                } label: {
                    ArrowDownCircled24()
                        .padding(.horizontal, 8)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 6)
    }
}

extension RecipeBasicItem where MenuContent == EmptyView {
    init(
        recipe: RecipeBasic,
        onRecipeTapped: @escaping (RecipeBasic) -> Void
    ) {
        self.init(
            recipe: recipe,
            onRecipeTapped: onRecipeTapped,
            menuContent: nil
        )
    }
}
