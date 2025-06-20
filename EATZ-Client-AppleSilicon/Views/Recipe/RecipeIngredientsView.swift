//
//  RecipeIngredientsView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/20/25.
//

import SwiftUI

struct RecipeIngredientsView: View {
    
    let ingredients: [RecipeIngredient]
    let onMainAction: () -> Void
    let onAddTapped: (Int64) -> Void
    let onActionTapped: (Int64, RecipeIngredientAction) -> Void
    let isUpdatingIngredient: [Int64: Bool]
    
    private var missingIngredientsCount: Int {
        ingredients.filter { !$0.ownedByUser }.count
    }
    
    private var isAllAdded: Bool {
        ingredients.allSatisfy { $0.ownedByUser }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                if isAllAdded {
                    CookableHeaderView(onViewRecipeTapped: onMainAction)
                } else {
                    UncookableHeaderView(
                        missingCount: missingIngredientsCount,
                        onActionTapped: onMainAction
                    )
                }
                VStack {
                    ForEach(ingredients, id: \.id) { item in
                        RecipeIngredientItemView(
                            id: item.id,
                            name: item.name,
                            isAdded: item.ownedByUser,
                            isLoading: isUpdatingIngredient[item.id] == true,
                            onAdd: { onAddTapped(item.id) },
                            onActionTapped: { action in onActionTapped(item.id, action) }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .animation(.easeInOut, value: isAllAdded)
            .transition(.opacity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct CookableHeaderView: View {
    let onViewRecipeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image("recipe-ingredients-cookable-available")
                .shadow(color: Color.init("76BD2F").opacity(0.75), radius: 8, x: 0, y: 4)
            VStack(spacing: 8) {
                Text("요리 가능")
                    .font(.system(size: 20, weight: .bold))
                Text("모든 도구와 재료가 준비되어 있어요.\n지금 바로 요리해볼까요?")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.init("828282"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: onViewRecipeTapped) {
                Text("레시피 보기")
            }
            .buttonStyle(SmallRoundedButtonStyle(type: .primary))
        }
    }
}

struct UncookableHeaderView: View {
    let missingCount: Int
    let onActionTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image("recipe-ingredients-cookable-unavailable")
                .shadow(color: Color.init("F2B518").opacity(0.75), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("재료 \(missingCount)개 필요")
                    .font(.system(size: 20, weight: .bold))
                Text("레시피를 요리하기 위해 필요한 재료가 있어요.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.init("828282"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                Button(action: onActionTapped) {
                    Text("재료 모두 추가")
                }
                Text("이미 필요한 모든 재료를 보유하고 있다면,\n필요한 재료만 한 번에 추가할 수 있어요.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.init("828282"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .buttonStyle(SmallRoundedButtonStyle(type: .primary))
        }
    }
}

