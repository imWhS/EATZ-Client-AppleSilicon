//
//  RecipeDetailRequirementsHeaderCookable.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsHeaderCookable: View {
    let onShowRecipeTapped: () -> Void
    
    init(_ onShowRecipeTapped: @escaping () -> Void) {
        self.onShowRecipeTapped = onShowRecipeTapped
    }
    
    var body: some View {
        contentView
        .padding(.horizontal, 20)
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            Group {
                Image("requirement-unavailable-62")
                    .shadow(color: Color.init(hex: "76BD2F").opacity(0.75), radius: 8, x: 0, y: 4)
                VStack(spacing: 4) {
                    Text("바로 요리할 수 있는 레시피")
                        .font(.system(size: 17, weight: .semibold))
                    Text("모든 도구와 재료가 준비되어 있어요.\n지금 요리해볼까요?")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray50)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                showRecipeButton
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.backgroundPrimary)
        .cornerRadius(24)
    }
    
    private var showRecipeButton: some View {
        Button("레시피 보기", action: onShowRecipeTapped)
            .buttonStyle(RoundedButtonStyle(.primary, .medium))
    }
}
