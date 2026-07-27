//
//  ExploreRecipeItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/15/25.
//

import SwiftUI

enum ExploreRecipeItemAction {
    case save, like, comment, addToPlanner, report
}

struct ExploreRecipeItem: View {
    let recipe: ExploreRecipe
    let cardWidth: CGFloat
    let onTappedRecipe: (ExploreRecipe) -> Void
    let onAction: (ExploreRecipe, ExploreRecipeItemAction) -> Void
    
    @State private var timerTask: Task<Void, Never>?
    
    init(
        _ recipe: ExploreRecipe,
        cardWidth: CGFloat,
        onTappedRecipe: @escaping (ExploreRecipe) -> Void,
        onAction: @escaping (ExploreRecipe, ExploreRecipeItemAction) -> Void) {
        self.recipe = recipe
        self.cardWidth = cardWidth
        self.onTappedRecipe = onTappedRecipe
        self.onAction = onAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { onTappedRecipe(recipe) }) {
                VStack(alignment: .leading, spacing: 0) {
                    RecipeItemThumbnail(
                        id: recipe.id,
                        isSaved: recipe.savedByUser,
                        imageUrlString: recipe.imageUrl,
                        width: cardWidth, onSaveTapped: { id in onAction(recipe, .save)}
                    )
                    ExploreItemDetailView(recipe: recipe, onAction: onAction)
                }
                .clipped()
                .cornerRadius(16)
            }
            .buttonStyle(ListItemButtonStyle())
            ExploreListItemBottomView(recipe: recipe, isCommentEnabled: recipe.commentEnabled, onAction: onAction)
        }
        .frame(width: cardWidth)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

private struct ExploreItemDetailView: View {
    let recipe: ExploreRecipe
    let onAction: (ExploreRecipe, ExploreRecipeItemAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            title
            HStack(alignment: .center, spacing: 4) {
                RecipeItemEssentialInfoView(cookingTime: recipe.cookingTime, prepTime: recipe.prepTime, ratingAverageScore: recipe.ratingAverageScore, ratingCount: recipe.ratingCount)
                Spacer()
                actionMenu
            }
            .padding(.top, 6)
            .padding(.bottom, 12)
            .padding(.horizontal, 12)
        }
        .background(Color.white)
    }
    
    private var title: some View {
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let titleHeight = font.lineHeight * 3
        
        return Text(recipe.title)
            .font(.system(size: 17, weight: .semibold))
            .lineLimit(3)
            .frame(height: titleHeight, alignment: .top)
            .padding(.top, 12)
            .padding(.bottom, 0)
            .padding(.horizontal, 12)
    }
    
    private var actionMenu: some View {
        Menu {
            Button {
                onAction(recipe, .addToPlanner)
            } label: {
                Label("플래너에 추가", systemImage: "plus.circle")
            }
            Button {
                onAction(recipe, .report)
            } label: {
                Label("신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowDownCircled20()
                .padding(4)
                .contentShape(Rectangle())
        }
    }
}

private struct ExploreListItemBottomView: View {
    let recipe: ExploreRecipe
    let isCommentEnabled: Bool
    let onAction: (ExploreRecipe, ExploreRecipeItemAction) -> Void

    private var isInitialCommentDisabled: Bool {
        recipe.commentCount == 0 && !isCommentEnabled
    }
    
    var body: some View {
        HStack(alignment: .center) {
            likeToggleButton
            VerticalDivider(padding: 0)
            commentButton
        }
        .frame(maxHeight: 26)
        .padding(.vertical, 8)
    }
    
    private var likeToggleButton: some View {
        if recipe.likedByUser {
            return bottomCountButton(
                imageName: "like-filled-16",
                count: recipe.likedCount,
                action: { onAction(recipe, .like) })
        } else {
            return bottomCountButton(
                imageName: "like-stroked-16",
                count: recipe.likedCount,
                action: { onAction(recipe, .like) }
            )
        }
    }
    
    private var commentButton: some View {
        return bottomCountButton(
            imageName: "comment-filled-16",
            count: recipe.commentCount,
            isDisabled: isInitialCommentDisabled,
            action: isInitialCommentDisabled ? {} : { onAction(recipe, .comment) })
    }
    
    private func bottomCountButton(imageName: String, count: Int, isDisabled: Bool = false, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            HStack(spacing: 4) {
                Image(imageName)
                    .foregroundStyle(isDisabled ? Color.init(hex: "A5A5A5") : Color.accentColor)
                Text(String(count))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.init(hex: "8B8B8B"))
            }
            .frame(maxWidth: .infinity)
            .padding(6)
        }
        .buttonStyle(ScaleDownButtonStyle(cornerRadius: 8, isDisabled: isDisabled))
        .padding(8)
    }
}
