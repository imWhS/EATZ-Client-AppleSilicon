//
//  RecipeRequirementContentView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/9/26.
//

import SwiftUI

struct RecipeRequirementContentView: View {
    let isMember: Bool
    let kitchenwares: [RecipeKitchenware]
    let ingredients: [RecipeIngredient]
    let cookability: RecipeDetailRequirementsCookability
    let onShowRecipeTapped: () -> Void
    let onAuth: () -> Void
    let onAddAllRequirements: () -> Void
    let onRequirementsAction: (RecipeDetailRequirementsAction) -> Void
    
    var missingKitchenwareCount: Int? {
        switch cookability {
        case .cookable: return nil
        case .uncookable(_, let missingKitchenwareCount): return missingKitchenwareCount
        }
    }
    
    var missingIngredientCount: Int? {
        switch cookability {
        case .cookable: return nil
        case .uncookable(let missingIngredientCount, _): return missingIngredientCount
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 0) {
                titleSection
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    if !kitchenwares.isEmpty {
                        RecipeDetailRequirementsKitchenwareSection(
                            isLoggedIn: isMember,
                            kitchenwares: kitchenwares,
                            missingKitchenwareCount: missingKitchenwareCount,
                            onAction: onRequirementsAction)
                    }
                    if !ingredients.isEmpty {
                        RecipeDetailRequirementsIngredientSection(
                            isLoggedIn: isMember,
                            ingredients: ingredients,
                            missingIngredientCount: missingIngredientCount,
                            onAction: onRequirementsAction)
                    }
                    
                    if kitchenwares.isEmpty && ingredients.isEmpty {
                        Text("레시피를 요리하기 위해 필요한 준비물이 없어요.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray35)
                            .padding(20)
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var titleSection: some View {
        RecipeDetailTitle("준비물")
            .padding(.vertical, 10)
    }
    
    private var headerSection: some View {
        Group {
            if isMember { recipeRequirementsContentHeader }
            else { RecipeDetailRequirementsHeaderGuest(onAuth: onAuth) }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var recipeRequirementsContentHeader: some View {
        switch cookability {
        case .cookable:
            RecipeDetailRequirementsHeaderCookable(onShowRecipeTapped: onShowRecipeTapped)
        case .uncookable(let missingIngredientCount, let missingKitchenwareCount):
            RecipeDetailRequirementsHeaderUncookable(
                missingKitchenwareCount: missingKitchenwareCount,
                missingIngredientCount: missingIngredientCount,
                onAddAllRequirements: onAddAllRequirements
            )
        }
    }
}
