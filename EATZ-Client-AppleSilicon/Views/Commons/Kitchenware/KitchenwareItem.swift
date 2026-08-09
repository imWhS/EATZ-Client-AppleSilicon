//
//  KitchenwareItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/21/25.
//

import SwiftUI
import Kingfisher

enum KitchenwareItemAction {
    case addToPantry(id: Int64)
    case removeFromPantry(id: Int64)
}

struct KitchenwareItem: View {
    let kitchenware: Kitchenware
    let action: (KitchenwareItemAction) -> Void
    
    init(_ kitchenware: Kitchenware,
         _ action: @escaping (KitchenwareItemAction) -> Void) {
        self.kitchenware = kitchenware
        self.action = action
    }

    var body: some View {
        KitchenwareRow(kitchenware, trailing: trailing)
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
        kitchenware.ownedByUser ? action(.removeFromPantry(id: kitchenware.id)) : action(.addToPantry(id: kitchenware.id))
    }
}
