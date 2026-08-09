//
//  ChecklistKitchenwareItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

enum ChecklistKitchenwareItemAction {
    case addToPantry
    case removeFromPantry
    case addNote
}

struct ChecklistKitchenwareItem: View {
    let kitchenware: ChecklistKitchenware
    let isLoading: Bool
    let action: (Int64, ChecklistKitchenwareItemAction) -> Void
    
    init(_ kitchenware: ChecklistKitchenware,
         isLoading: Bool,
         action: @escaping (Int64, ChecklistKitchenwareItemAction) -> Void) {
        self.kitchenware = kitchenware
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        HStack {
            imageView
            Image(kitchenware.missing ? "recipe-ingredients-cookable-needed" : "recipe-ingredients-cookable-added")
            Text(kitchenware.name)
                .font(.system(size: 17, weight: .medium))
            if isLoading {
                ProgressView()
            } else {
                if !kitchenware.missing { actionMenu }
                else {
                    actionButton(image: "add-circled-20", action: { action(kitchenware.id, .addToPantry) })
                }
            }
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
