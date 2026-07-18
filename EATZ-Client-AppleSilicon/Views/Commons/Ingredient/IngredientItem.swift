//
//  IngredientItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import SwiftUI

enum IngredientItemAction {
    case like(id: Int64)
    case unlike(id: Int64)
    case addToPantry(id: Int64)
    case removeFromPantry(id: Int64)
}

struct IngredientItem<Destination: View>: View {
    let ingredient: Ingredient
    let isLinkable: Bool
    let linkDestination: Destination?
    let onAction: (IngredientItemAction) -> Void
    
    init(_ ingredient: Ingredient,
         isLinkable: Bool = false,
         linkDestination: Destination? = nil,
         onAction: @escaping (IngredientItemAction) -> Void) {
        self.ingredient = ingredient
        self.isLinkable = isLinkable
        self.linkDestination = linkDestination
        self.onAction = onAction
    }
    
    var body: some View {
        IngredientRow(ingredient,
                      isLinkable: isLinkable,
                      linkDestination: ExploreIngredientsChildList(parentId: ingredient.id, parentName: ingredient.name),
                      trailing: trailing)
        .padding(.horizontal, 20)
    }
    
    private func trailing() -> some View {
        HStack(spacing: 0) {
            VerticalDivider(padding: 8)
            actionButtonContainer
        }
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
        ingredient.likedByUser ? onAction(.unlike(id: ingredient.id)) : onAction(.like(id: ingredient.id))
    }
    
    private func handleTogglePantry() -> Void {
        ingredient.ownedByUser ? onAction(.removeFromPantry(id: ingredient.id)) : onAction(.addToPantry(id: ingredient.id))
    }
}
