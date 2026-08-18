//
//  ChecklistKitchenwareItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

enum ChecklistKitchenwareAction {
    case addToPantry
    case removeFromPantry
    case addNote
}

struct ChecklistKitchenwareItem: View {
    let kitchenware: ChecklistKitchenware
    let disabled: Bool
    let isLoading: Bool
    let action: (Int64, ChecklistKitchenwareAction) -> Void
    
    init(_ kitchenware: ChecklistKitchenware,
         disabled: Bool,
         isLoading: Bool,
         action: @escaping (Int64, ChecklistKitchenwareAction) -> Void) {
        self.kitchenware = kitchenware
        self.disabled = disabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        HStack {
            leadingSection
            trailingSection
        }
    }
    
    private var imageView: some View {
        KFImage(URL(imageUrlString: kitchenware.imageUrl ?? ""))
            .placeholder {
                Circle().fill(Color.white)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Circle())
            .padding(.vertical, 0.5)
    }
    
    @ViewBuilder
    private var leadingSection: some View {
        HStack {
            imageView
            Image(kitchenware.missing ? "recipe-ingredients-cookable-needed" : "recipe-ingredients-cookable-added")
            Text(kitchenware.name)
                .font(.system(size: 17, weight: .medium))
        }
    }
    
    @ViewBuilder
    private var trailingSection: some View {
        HStack {
            if isLoading {
                ProgressView()
            } else {
                Group {
                    if !kitchenware.missing { actionMenu }
                    else {
                        actionButton(image: "add-circled-20", action: { action(kitchenware.id, .addToPantry) })
                    }
                }
                .opacity(disabled ? 0.5 : 1)
                .disabled(disabled)
            }
        }
    }
    
    private var actionMenu: some View {
        Menu {
            Button(role: .destructive) {
                action(kitchenware.id, .removeFromPantry)
            } label: {
                Label("보관함에서 제거", systemImage: "trash")
            }
        } label: {
            ArrowDownCircled24()
        }
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4) }
    }
}
