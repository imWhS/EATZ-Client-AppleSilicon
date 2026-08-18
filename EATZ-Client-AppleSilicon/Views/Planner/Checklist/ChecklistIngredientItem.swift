//
//  ChecklistIngredientItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

struct ChecklistIngredientItem: View {
    let ingredient: ChecklistIngredient
    let disabled: Bool
    let isLoading: Bool
    let showDivider: Bool
    let action: (Int64, ChecklistIngredientAction) -> Void
    
    private let verticalSpacing: CGFloat = 10.0
    
    init(
        _ ingredient: ChecklistIngredient,
        disabled: Bool,
        isLoading: Bool,
        showDivider: Bool = true,
        action: @escaping (Int64, ChecklistIngredientAction) -> Void) {
            self.ingredient = ingredient
            self.disabled = disabled
            self.isLoading = isLoading
            self.showDivider = showDivider
            self.action = action
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(ingredient.missing ? "recipe-ingredients-cookable-needed" : "recipe-ingredients-cookable-added")
                .padding(.vertical, 6.5)
            
            VStack(spacing: verticalSpacing) {
                HStack {
                    leadingSection
                    trailingSection
                }
                
                if showDivider {
                    HorizontalDivider(padding: 0)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var leadingSection: some View {
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
    }
    
    @ViewBuilder
    private var trailingSection: some View {
        if isLoading {
            ProgressView()
                .padding(4.75)
        } else {
            Group {
                if !ingredient.missing {
                    actionButton(image: "add-circled-20", action: { action(ingredient.id, .addToPantry) }).opacity(0).disabled(true)
                    actionMenu
                }
                else {
                    actionButton(image: "add-circled-22", action: { action(ingredient.id, .addToPantry) })
                }
            }
            .opacity(disabled ? 0.5 : 1)
            .disabled(disabled)
        }
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

enum ChecklistIngredientAction {
    case addToPantry
    case removeFromPantry
    case like
    case unlike
    case addNote
    case setExpiryDate
}

