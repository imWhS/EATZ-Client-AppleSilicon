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
    let action: (Int64, ChecklistIngredientItemAction) -> Void
    
    init(_ ingredient: ChecklistIngredient,
         isLoading: Bool,
         action: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.ingredient = ingredient
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        HStack {
            Image(ingredient.missing ? "recipe-ingredients-cookable-needed" : "recipe-ingredients-cookable-added")
            
            HStack(spacing: 4) {
                Group {
                    if ingredient.parentCoupled,
                       let coupledParentName = ingredient.coupledParentName,
                       coupledParentName.isEmpty == false {
                        Text(coupledParentName)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.gray60)
                    }
                    Text(ingredient.name)
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                }
            }
            
            if isLoading {
                ProgressView()
            } else {
                if !ingredient.missing {
                    actionButton(image: "add-circled-20", action: { action(ingredient.id, .addToPantry) }).opacity(0).disabled(true)
                    actionMenu
                }
                else {
                    actionButton(image: "add-circled-22", action: { action(ingredient.id, .addToPantry) })
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionMenu: some View {
        Menu {
            Button(role: .destructive) {
                action(ingredient.id, .removeFromPantry)
            } label: {
                Label("보관함에서 제거", systemImage: "trash")
            }
            
            if ingredient.likedByUser {
                Button {
                    action(ingredient.id, .unlike)
                } label: {
                    Label("재료 좋아요 취소", systemImage: "heart.slash")
                }
                
            } else {
                Button {
                    action(ingredient.id, .like)
                } label: {
                    Label("재료 좋아요", systemImage: "heart")
                }
            }
        } label: {
            ArrowDownCircled24()
                .padding(4)
        }
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }
    }
}
