//
//  ChecklistCookabilityView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/6/25.
//

import SwiftUI

struct ChecklistCookabilityView: View {
    let cookability: ChecklistCookability
    let missingKitchenwareCount: Int
    let missingIngredientCount: Int
    let planItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let kitchenwareItemAction: (Int64, ChecklistKitchenwareItemAction) -> Void
    let ingredientItemAction: (Int64, ChecklistIngredientItemAction) -> Void
    
    init(cookability: ChecklistCookability,
         _ missingKitchenwareCount: Int,
         _ missingIngredientCount: Int,
         _ planItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ kitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareItemAction) -> Void,
         _ ingredientItemAction: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.cookability = cookability
        self.missingKitchenwareCount = missingKitchenwareCount
        self.missingIngredientCount = missingIngredientCount
        self.planItemAction = planItemAction
        self.kitchenwareItemAction = kitchenwareItemAction
        self.ingredientItemAction = ingredientItemAction
    }
    
    init(cookability: ChecklistCookability,
         _ planItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ kitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareItemAction) -> Void,
         _ ingredientItemAction: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.cookability = cookability
        self.missingKitchenwareCount = 0
        self.missingIngredientCount = 0
        self.planItemAction = planItemAction
        self.kitchenwareItemAction = kitchenwareItemAction
        self.ingredientItemAction = ingredientItemAction
    }
    
    private var sortedKitchenwares: [ChecklistKitchenware] {
        cookability.requirements.kitchenwares.sorted { (kitchenware1, kitchenware2) in
            (kitchenware1.missing && !kitchenware2.missing) }
    }
    
    private var sortedIngredients: [ChecklistIngredient] {
        cookability.requirements.ingredients.sorted { (ingredient1, ingredient2) in
            (ingredient1.missing && !ingredient2.missing) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            planList
            
            if !sortedKitchenwares.isEmpty && !sortedIngredients.isEmpty {
                HorizontalDivider()
                VStack(spacing: 0) {
                    if !sortedKitchenwares.isEmpty {
                        kitchenwareList
                    }
                    
                    if !sortedIngredients.isEmpty {
                        ingredientList
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
    
    private var planList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                LazyHStack {
                    ForEach(cookability.plans) { plan in
                        ChecklistPlanItem(plan, action: planItemAction)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var kitchenwareList: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VerticalLabeledValueView(
                    label: "총 도구 수",
                    value: "\(sortedKitchenwares.count)개")
                if 0 < missingKitchenwareCount {
                    VerticalLabeledValueView(
                        label: "필요한 도구 수",
                        value: "\(missingKitchenwareCount)개",
                        style: .secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 0) {
                    ForEach(sortedKitchenwares) { kitchenware in
                        ChecklistKitchenwareItem(kitchenware, isLoading: false, action: kitchenwareItemAction)
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.horizontal, 10)
                .animation(.default, value: sortedKitchenwares)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var ingredientList: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VerticalLabeledValueView(
                    label: "총 재료 수",
                    value: "\(sortedIngredients.count)개")
                
                if 0 < missingIngredientCount {
                    VerticalLabeledValueView(
                        label: "필요한 재료 수",
                        value: "\(missingIngredientCount)개",
                        style: .secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .center, spacing: 12) {
                    ForEach(sortedIngredients) { ingredient in
                        ChecklistIngredientItem(ingredient, isLoading: false, action: ingredientItemAction)
                    }
                }
                .animation(.default, value: sortedIngredients)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func headerView(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 20)
            Spacer()
        }
    }
}
