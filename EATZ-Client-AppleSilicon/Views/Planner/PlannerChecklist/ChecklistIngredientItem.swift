//
//  ChecklistIngredientItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

enum ChecklistIngredientItemAction {
    case addToPantry
    case removeFromPantry
    case like
    case unlike
    case addNote
    case setExpiryDate
}

struct ChecklistIngredientItem: View {
    let ingredient: ChecklistIngredient
    let isLoading: Bool
    let onAction: (Int64, ChecklistIngredientItemAction) -> Void
    
    init(_ ingredient: ChecklistIngredient,
         isLoading: Bool,
         onAction: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.ingredient = ingredient
        self.isLoading = isLoading
        self.onAction = onAction
    }
    
    var body: some View {
        HStack {
            Image(ingredient.missing ? "recipe-ingredients-cookable-needed" : "recipe-ingredients-cookable-added")
            Text(ingredient.name)
                .font(.system(size: 17, weight: .medium))
            Spacer()
            
            if isLoading {
                ProgressView()
            } else {
                if !ingredient.missing {
                    actionButton(image: "add-to-pantry-18", action: { onAction(ingredient.id, .addToPantry) }).opacity(0).disabled(true)
                    actionMenu
                }
                else {
                    actionButton(image: "add-to-pantry-18", action: { onAction(ingredient.id, .addToPantry) })
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionMenu: some View {
        Menu {
            Button(role: .destructive) {
                onAction(ingredient.id, .removeFromPantry)
            } label: {
                Label("보관함에서 제거", systemImage: "trash")
            }
            
            if ingredient.likedByUser {
                Button {
                    onAction(ingredient.id, .unlike)
                } label: {
                    Label("재료 좋아요 취소", systemImage: "heart.slash")
                }
                
            } else {
                Button {
                    onAction(ingredient.id, .like)
                } label: {
                    Label("재료 좋아요", systemImage: "heart")
                }
            }
        } label: {
            ArrowDownCircled20()
                .padding(4)
        }
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }
    }
}
