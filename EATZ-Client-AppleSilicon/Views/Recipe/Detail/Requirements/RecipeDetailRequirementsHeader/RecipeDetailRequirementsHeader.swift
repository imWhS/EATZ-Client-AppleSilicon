//
//  RecipeDetailRequirementsHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/18/26.
//

import SwiftUI

struct RecipeDetailRequirementsHeader: View {
    let cookability: RecipeDetailRequirementsCookability
    let onShowRecipeTapped: () -> Void
    let onAddAllRequirements: () -> Void
    
    init(
        _ cookability: RecipeDetailRequirementsCookability,
        _ onShowRecipeTapped: @escaping () -> Void,
        _ onAddAllRequirements: @escaping () -> Void)
    {
        self.cookability = cookability
        self.onShowRecipeTapped = onShowRecipeTapped
        self.onAddAllRequirements = onAddAllRequirements
    }
    
    private var missingKitchenwareLabel: String {
        switch cookability {
        case .cookable: return ""
        case .uncookable(let missingIngredientCount, let missingKitchenwareCount):
            if missingKitchenwareCount == 0 { return "" }
            else {
                let suffix = missingIngredientCount == 0 ? "" : "와"
                return "도구 \(missingKitchenwareCount)개\(suffix)"
            }
        }
    }

    private var missingIngredientLabel: String {
        switch cookability {
        case .cookable: return ""
        case .uncookable(let missingIngredientCount, let missingKitchenwareCount):
            if missingIngredientCount == 0 { return "" }
            else {
                let prefix = missingKitchenwareCount == 0 ? "" : " "
                return "\(prefix)재료 \(missingIngredientCount)개"
            }
        }
    }
    
    private var title: String {
        switch cookability {
        case .cookable: return "바로 요리할 수 있는 레시피"
        case .uncookable: return "바로 요리할 수 없는 레시피"
        }
    }
    
    private var subtitle: String {
        switch cookability {
        case .cookable:
            return "모든 도구와 재료가 준비되어 있어요.\n지금 요리해볼까요?"
        case .uncookable:
            return "\(missingKitchenwareLabel)\(missingIngredientLabel)가 부족해요. 이미 필요한 도구와 재료를 모두 준비했다면, 보관함에 추가해두세요."
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            contentSection
            purchaseButton
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundPrimary)
        .cornerRadius(24)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: cookability)
    }
    
    private var cookableImage: some View {
        if case .cookable = cookability {
            Image("requirement-available-62")
                .shadow(color: Color.init(hex: "76BD2F").opacity(0.75), radius: 8, x: 0, y: 4)
        } else {
            Image("requirement-unavailable-62")
                .shadow(color: Color.init(hex: "F2B518").opacity(0.75), radius: 8, x: 0, y: 4)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            cookableImage
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .id(title)
                    Text(subtitle)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.gray50)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(title)
                }
                
                switch cookability {
                case .cookable: showRecipeButton
                case .uncookable: addAllToPantryButton
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var addAllToPantryButton: some View {
        Button(action: onAddAllRequirements) {
            HStack(spacing: 4) {
                Image("add-circled-16").foregroundStyle(Color.white)
                Text("모두 보관함에 추가")
            }}
        .buttonStyle(RoundedButtonStyle(.primary, .medium))
    }
    
    private var purchaseButton: some View {
        Button(action: onAddAllRequirements) {
            VStack(spacing: 0) {
                HorizontalDivider()
                HStack(spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("준비물 구입")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("필요한 도구와 재료를 온라인에서 준비해보세요.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.gray50)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Image("external-link-14-light")
                }
                .padding(20)
            }
        }
    }
    
    private var showRecipeButton: some View {
        Button("레시피 보기", action: onShowRecipeTapped)
            .buttonStyle(RoundedButtonStyle(.primary, .medium))
    }
}
