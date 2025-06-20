//
//  RecipeIngredientView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/22/25.
//

import SwiftUI

struct RecipeIngredientItemView: View {
    
    let id: Int64
    let name: String
    let isAdded: Bool?
    let isLoading: Bool
    let onAdd: () -> Void
    let onActionTapped: ((RecipeIngredientAction) -> Void)
    
    var body: some View {
        HStack {
            ingredientInfo
            actionArea
        }
        .frame(minHeight: 48)
        .background(Color.init("F8F8F8"))
        .cornerRadius(16)
        
    }
    
    private var ingredientInfo: some View {
        HStack {
            if let isAdded = isAdded {
                Image(isAdded ? "recipe-ingredients-cookable-added" : "recipe-ingredients-cookable-needed")
            } else {
                EmptyView()
            }

            Text(name)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
    }

    private var actionArea: some View {
        HStack {
            switch isAdded {
            case true:
                actionMenu
            case false:
                AddRecipeToListButton(isLoading: isLoading, action: onAdd)
            default:
                EmptyView()
            }
        }
        .padding(10)
    }
    
    private var actionMenu: some View {
        Menu {
            Button(role: .destructive) {
                onActionTapped(.remove)
            } label: {
                Label("보관함에서 제거", systemImage: "trash")
            }

            Button {
                onActionTapped(.like)
            } label: {
                Label("좋아요", systemImage: "heart")
            }
        } label: {
            Image("action-button")
                .padding(.horizontal, 4)
        }
    }
    
}


struct AddRecipeToListButton: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            Button(action: action) {
                HStack(spacing: 4) {
                    Image("add-12")
                    Text("추가")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Color.init("ECECEC"))
                .cornerRadius(6)
            }
        }
    }
    
}

enum RecipeIngredientAction {
    case remove
    case like
    case addNote
    case setExpiryDate
}

#Preview {
    VStack(spacing: 12) {
        RecipeIngredientItemView(
            id: 1,
            name: "고추장",
            isAdded: true,
            isLoading: false,
            onAdd: { print("추가") },
            onActionTapped: { action in
                switch action {
                case .remove: print("보관함에서 제거")
                case .like: print("좋아요")
                case .addNote: print("메모 추가")
                case .setExpiryDate: print("유통기한 등록")
                }
            }
        )
        RecipeIngredientItemView(
            id: 1,
            name: "고추장",
            isAdded: false,
            isLoading: false,
            onAdd: { print("추가") },
            onActionTapped: { action in
                switch action {
                case .remove: print("보관함에서 제거")
                case .like: print("좋아요")
                case .addNote: print("메모 추가")
                case .setExpiryDate: print("유통기한 등록")
                }
            }
        )
        RecipeIngredientItemView(
            id: 3,
            name: "소고기 (비로그인 유저)",
            isAdded: nil,
            isLoading: false,
            onAdd: { print("추가") },
            onActionTapped: { action in print(action) }
        )
    }
    .padding()
}
