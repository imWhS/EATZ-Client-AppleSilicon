//
//  RecipeDetailEssentialSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI

struct RecipeDetailEssentialSection: View {
    var detailState: RecipeDetailState
    
    let onLikeTapped: () -> Void
    let onAddToPlannerTapped: () -> Void
    let onToggleSaveTapped: () -> Void
    let onShowRecipeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            RecipeDetailSummarySection(recipe: detailState.recipe)
            RecipeDetailInteractionBar(
                likedCount: detailState.likedCount,
                isLiked: detailState.isLiked,
                isSaved: detailState.isSaved,
                onLikeTapped: onLikeTapped,
                onAddToPlannerTapped: onAddToPlannerTapped,
                onToggleSaveTapped: onToggleSaveTapped,
                onShowRecipeTapped: onShowRecipeTapped)
        }
        .padding(.vertical, 10)
    }
}
