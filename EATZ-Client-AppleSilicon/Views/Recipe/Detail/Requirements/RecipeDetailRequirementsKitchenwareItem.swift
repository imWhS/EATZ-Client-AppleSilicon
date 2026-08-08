//
//  RecipeDetailRequirementsKitchenwareItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI
import Kingfisher

struct RecipeDetailRequirementsKitchenwareItem: View {
    let kitchenware: RecipeKitchenware
    let isLoggedIn: Bool
    let onAction: (RecipeDetailRequirementsAction) -> Void
    
    var body: some View {
        KitchenwareRow(kitchenware, style: .outlined, isEnabled: isLoggedIn, icon, trailing: trailing)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private func icon() -> some View {
        if isLoggedIn {
            Image(kitchenware.ownedByUser ? "recipe-ingredients-cookable-added" : "recipe-ingredients-cookable-needed")
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
                actionButton(image: kitchenware.ownedByUser ? "remove-from-pantry-18" : "add-circled-18", action: handleTogglePantry)
            }
            .buttonStyle(SmallBorderlessButtonStyle())
        }
        .padding(4)
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }
    }
    
    private func handleTogglePantry() -> Void {
        onAction(.toggleKitchenwareAddition(id: kitchenware.id))
    }
}
