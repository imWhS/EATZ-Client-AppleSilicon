//
//  RecipeDetailRequirementsIngredientItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsIngredientItem: View {
    let isLoggedIn: Bool
    let ingredient: RecipeIngredient
    let onAction: (RecipeDetailRequirementsAction) -> Void
    
    var body: some View {
        IngredientRow(ingredient,
                      appearance: .outlined,
                      isEnabled: isLoggedIn,
                      icon: icon,
                      trailing: trailing)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func icon() -> some View {
        if isLoggedIn {
            Image(ingredient.ownedByUser ? "recipe-ingredients-cookable-added" : "recipe-ingredients-cookable-needed")
        } else { EmptyView() }
    }
    
    @ViewBuilder
    private func trailing() -> some View {
        if isLoggedIn {
            HStack(spacing: 0) {
                VerticalDivider(padding: 8)
                actionButtonContainer
            }
        } else { EmptyView() }
    }
    
    private var actionButtonContainer: some View {
        HStack(spacing: 0) {
            Group {
                actionButton(image: ingredient.likedByUser ? "like-filled-18" : "like-stroked-18", action: handleToggleLike)
                actionButton(image: ingredient.ownedByUser ? "remove-from-pantry-18" : "add-to-pantry-18", action: handleTogglePantry)
            }
            .buttonStyle(SmallBorderlessButtonStyle())
        }
        .padding(4)
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }
    }
    
    private func handleToggleLike() -> Void {
        onAction(.toggleLikeIngredient(id: ingredient.id))
    }
    
    private func handleTogglePantry() -> Void {
        onAction(.toggleIngredientAddition(id: ingredient.id))
    }
}
