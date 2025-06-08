//
//  RecipeIngredientsPublicView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/23/25.
//

import SwiftUI

struct RecipeIngredientsPublicView: View {
    
    let ingredients: [RecipeIngredient]
    let onMainAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("이 레시피, 지금 바로 요리할 수 있을까요?")
                        .font(.system(size: 20, weight: .bold))
                    Text("로그인 또는 가입해보세요. 내 재료로 바로 요리가 가능한지, 어떤 재료가 더 필요한지 편리하게 확인할 수 있어요.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.init("828282"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(action: onMainAction) {
                    Text("이메일로 시작")
                }
                .buttonStyle(SmallRoundedButtonStyle(type: .primary))
            }
            
            VStack(spacing: 12) {
                ForEach(ingredients, id: \.id) { item in
                    HStack {
                        Text(item.name)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .frame(minHeight: 48)
                    .background(Color("F8F8F8"))
                    .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
}

#Preview {
    RecipeIngredientsPublicView(
        ingredients: [
            RecipeIngredient(id: 1, name: "고추장", ownedByUser: true),
            RecipeIngredient(id: 2, name: "양파", ownedByUser: false),
            RecipeIngredient(id: 3, name: "돼지고기 앞다리살", ownedByUser: false)
        ],
        onMainAction: { print("login") }
    )
}
