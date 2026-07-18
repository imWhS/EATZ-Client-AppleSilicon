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
                    RecipeDetailRequirementsKitchenwareSection(
                        isLoggedIn: isMember,
                        kitchenwares: kitchenwares,
                        missingKitchenwareCount: missingKitchenwareCount,
                        onAction: onRequirementsAction)
                    RecipeDetailRequirementsIngredientSection(
                        isLoggedIn: isMember,
                        ingredients: ingredients,
                        missingIngredientCount: missingIngredientCount,
                        onAction: onRequirementsAction)
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
