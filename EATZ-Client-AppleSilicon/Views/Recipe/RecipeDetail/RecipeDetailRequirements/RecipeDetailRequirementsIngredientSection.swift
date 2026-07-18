//
//  RecipeDetailRequirementsIngredientSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsIngredientSection: View {
    let isLoggedIn: Bool
    let ingredients: [RecipeIngredient]
    let missingIngredientCount: Int?
    let onAction: (RecipeDetailRequirementsAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                VerticalLabeledValueView(
                    label: "총 재료 수",
                    value: "\(ingredients.count)개")
                if isLoggedIn,
                    let missingIngredientCount = missingIngredientCount,
                    0 < missingIngredientCount {
                    VerticalLabeledValueView(
                        label: "필요한 재료 수",
                        value: "\(missingIngredientCount)개",
                        style: .secondary
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            recipeRequirementsIngredientList
        }
    }
    
    
    private var recipeRequirementsIngredientList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ingredients) { ingredient in
                RecipeDetailRequirementsIngredientItem(
                    isLoggedIn: isLoggedIn,
                    ingredient: ingredient,
                    onAction: onAction)
            }
        }
        .padding(.vertical, 6)
    }
}
