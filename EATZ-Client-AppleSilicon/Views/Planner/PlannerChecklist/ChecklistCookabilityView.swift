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
    let onPlanItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let onKitchenwareItemAction: (Int64, ChecklistKitchenwareItemAction) -> Void
    let onIngredientItemAction: (Int64, ChecklistIngredientItemAction) -> Void
    
    init(cookability: ChecklistCookability,
         _ missingKitchenwareCount: Int,
         _ missingIngredientCount: Int,
         _ onPlanItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ onKitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareItemAction) -> Void,
         _ onIngredientItemAction: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.cookability = cookability
        self.missingKitchenwareCount = missingKitchenwareCount
        self.missingIngredientCount = missingIngredientCount
        self.onPlanItemAction = onPlanItemAction
        self.onKitchenwareItemAction = onKitchenwareItemAction
        self.onIngredientItemAction = onIngredientItemAction
    }
    
    init(cookability: ChecklistCookability,
         _ onPlanItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ onKitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareItemAction) -> Void,
         _ onIngredientItemAction: @escaping (Int64, ChecklistIngredientItemAction) -> Void) {
        self.cookability = cookability
        self.missingKitchenwareCount = 0
        self.missingIngredientCount = 0
        self.onPlanItemAction = onPlanItemAction
        self.onKitchenwareItemAction = onKitchenwareItemAction
        self.onIngredientItemAction = onIngredientItemAction
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
            VStack(spacing: 0) {
                kitchenwareList
                ingredientList
            }
            .padding(.vertical, 10)
        }
    }
    
    private var planList: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    LazyHStack {
                        ForEach(cookability.plans) { plan in
                            ChecklistPlanItem(plan, onAction: onPlanItemAction)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            HorizontalDivider()
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
                        ChecklistKitchenwareItem(kitchenware, isLoading: false, onAction: onKitchenwareItemAction)
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
                        ChecklistIngredientItem(ingredient, isLoading: false, onAction: onIngredientItemAction)
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
