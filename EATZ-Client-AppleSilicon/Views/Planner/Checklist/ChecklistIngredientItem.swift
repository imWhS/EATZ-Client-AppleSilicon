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
    let isDisabled: Bool
    let isLoading: Bool
    let showDivider: Bool
    let action: (Int64, ChecklistIngredientAction) -> Void
    
    private let verticalSpacing: CGFloat = 10.0
    private let commonHeight: CGFloat = 26.0
    
    init(
        _ ingredient: ChecklistIngredient,
        isDisabled: Bool,
        isLoading: Bool,
        showDivider: Bool = true,
        action: @escaping (Int64, ChecklistIngredientAction) -> Void) {
            self.ingredient = ingredient
            self.isDisabled = isDisabled
            self.isLoading = isLoading
            self.showDivider = showDivider
            self.action = action
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(ingredient.missing ? "requirement-needed-18" : "requirement-added-18")
                .frame(height: commonHeight)
            
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
            .frame(minHeight: commonHeight, maxHeight: commonHeight)
        }
    }
    
    @ViewBuilder
    private var trailingSection: some View {
        Group {
            if isLoading {
                ProgressView()
                    .padding(4.75)
            } else {
                Group {
                    if !ingredient.missing {
                        actionButton(image: "add-circled-22", action: { action(ingredient.id, .addToPantry) }).opacity(0).disabled(true)
                        actionMenu
                    }
                    else {
                        actionButton(image: "add-circled-22", action: { action(ingredient.id, .addToPantry) })
                    }
                }
                .opacity(isDisabled ? 0.25 : 1)
                .disabled(isDisabled)
            }
        }
        .frame(width: commonHeight, height: commonHeight)
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
            ArrowCircledDown24()
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

