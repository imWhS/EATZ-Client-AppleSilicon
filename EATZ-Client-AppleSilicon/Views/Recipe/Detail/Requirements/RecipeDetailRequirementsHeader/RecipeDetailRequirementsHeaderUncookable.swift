//
//  RecipeDetailRequirementsUncookableHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsHeaderUncookable: View {
    let missingKitchenwareCount: Int
    let missingIngredientCount: Int
    let onAddAllRequirements: () -> Void

    private var missingKitchenwareLabel: String {
        if missingKitchenwareCount == 0 { return "" }
        else {
            let suffix = missingIngredientCount == 0 ? "" : "와"
            return "도구 \(missingKitchenwareCount)개\(suffix)"
        }
    }

    private var missingIngredientLabel: String {
        if missingIngredientCount == 0 { return "" }
        else {
            let prefix = missingKitchenwareCount == 0 ? "" : " "
            return "\(prefix)재료 \(missingIngredientCount)개"
        }
    }
    
    init(_ missingKitchenwareCount: Int, _ missingIngredientCount: Int, _ onAddAllRequirements: @escaping () -> Void) {
        self.missingKitchenwareCount = missingKitchenwareCount
        self.missingIngredientCount = missingIngredientCount
        self.onAddAllRequirements = onAddAllRequirements
    }
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            Group {
                Image("recipe-ingredients-cookable-unavailable")
                    .shadow(color: Color.init(hex: "F2B518").opacity(0.75), radius: 8, x: 0, y: 4)
                VStack(spacing: 4) {
                    Text("바로 요리할 수 없는 레시피")
                        .font(.system(size: 17, weight: .semibold))
                    Text("\(missingKitchenwareLabel)\(missingIngredientLabel)가 부족해요. 이미 필요한 도구와 재료를 모두 준비했다면, 보관함에 추가해두세요.")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray50)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: missingKitchenwareCount)
                        .animation(.snappy, value: missingIngredientCount)
                }
                addAllToPantryButton
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.backgroundPrimary)
        .cornerRadius(24)
    }
    
    private var addAllToPantryButton: some View {
        Button(action: onAddAllRequirements) {
            HStack(spacing: 4) {
                Image("add-circled-16").foregroundStyle(Color.white)
                Text("모두 보관함에 추가")
            }}
        .buttonStyle(RoundedButtonStyle(.primary, .medium))
    }
}
