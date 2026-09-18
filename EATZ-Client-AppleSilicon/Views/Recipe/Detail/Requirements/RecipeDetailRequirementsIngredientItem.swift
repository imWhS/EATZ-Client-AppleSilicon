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
    let action: (RecipeDetailRequirementsAction) -> Void
    
    private var isPurchasable: Bool {
        if (isLoggedIn == false) {
            return true
        }
        
        return !ingredient.ownedByUser
    }
    
    init(
        _ isLoggedIn: Bool,
        _ ingredient: RecipeIngredient,
        _ action: @escaping (RecipeDetailRequirementsAction) -> Void)
    {
        self.isLoggedIn = isLoggedIn
        self.ingredient = ingredient
        self.action = action
    }
    
    var body: some View {
        IngredientRow(ingredient,
                      style: .outlined,
                      isEnabled: isLoggedIn,
                      isPurchasable: isPurchasable,
                      onPurchaseTapped: handlePurchase,
                      icon: icon,
                      trailing: trailing)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func icon() -> some View {
        if isLoggedIn { Image(ingredient.ownedByUser ? "requirement-added-18" : "requirement-needed-18") }
        else { EmptyView() }
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
            actionButton(ingredient.likedByUser ? "like-filled-18" : "like-stroked-18", handleToggleLike)
            actionButton(ingredient.ownedByUser ? "remove-from-pantry-18" : "add-circled-18", handleTogglePantry)
        }
        .padding(4)
    }
    
    private func actionButton(_ image: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }.buttonStyle(SmallBorderlessButtonStyle())
    }
    
    private func handleToggleLike() -> Void {
        action(.toggleLikeIngredient(id: ingredient.id))
    }
    
    private func handleTogglePantry() -> Void {
        action(.toggleIngredientAddition(id: ingredient.id))
    }
    
    private func handlePurchase() -> Void {
        action(.purchase(id: ingredient.id))
    }
}
