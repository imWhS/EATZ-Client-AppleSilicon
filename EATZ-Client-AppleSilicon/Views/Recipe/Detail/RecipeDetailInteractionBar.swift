//
//  RecipeDetailInteractionBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI

struct RecipeDetailInteractionBar: View {
    let likedCount: Int
    let isLiked: Bool
    let isSaved: Bool
    
    let onLikeTapped: () -> Void
    let onAddToPlannerTapped: () -> Void
    let onToggleSaveTapped: () -> Void
    let onShowRecipeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            showRecipeButton
            subButtonsSection
        }
    }
    
    private var showRecipeButton: some View {
        Button(action: onShowRecipeTapped) {
            Text("레시피 보기").frame(maxWidth: .infinity)
        }
        .buttonStyle(CapsuleLargeButtonStyle(appearance: .primary))
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var subButtonsSection: some View {
        HStack(spacing: 4) {
            VerticalAlignedIconTitleButton(
                image: isLiked ? "like-filled-18" : "like-stroked-18",
                title: (likedCount == 0) ? "좋아요" : "\(likedCount)") {
                onLikeTapped()
            }
            VerticalDivider(padding: 10)
            VerticalAlignedIconTitleButton(
                image: "add-to-planner-20",
                title: "플래너에 추가") {
                onAddToPlannerTapped()
            }
            VerticalDivider(padding: 10)
            VerticalAlignedIconTitleButton(
                image: isSaved ?  "recipe-list-item-save-filled" : "recipe-list-item-save-stroked",
                title: isSaved ? "저장 취소" : "저장") {
                onToggleSaveTapped()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
