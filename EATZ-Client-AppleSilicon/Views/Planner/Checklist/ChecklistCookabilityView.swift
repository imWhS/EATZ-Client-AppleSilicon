//
//  ChecklistCookabilityView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/6/25.
//

import SwiftUI

struct ChecklistCookabilityView: View {
    let cookability: ChecklistCookability
    let isUpdatingPantry: Bool
    let pendingKitchenwareIds: Set<Int64>
    let pendingIngredientIds: Set<Int64>
    let missingKitchenwareCount: Int
    let missingIngredientCount: Int
    let planItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let kitchenwareItemAction: (Int64, ChecklistKitchenwareAction) -> Void
    let ingredientItemAction: (Int64, ChecklistIngredientAction) -> Void
    
    init(
        cookability: ChecklistCookability,
        _ isUpdatingPantry: Bool,
         _ missingKitchenwareCount: Int,
         _ missingIngredientCount: Int,
         _ pendingKitchenwareIds: Set<Int64>,
         _ pendingIngredientIds: Set<Int64>,
         _ planItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ kitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareAction) -> Void,
         _ ingredientItemAction: @escaping (Int64, ChecklistIngredientAction) -> Void)
    {
        self.cookability = cookability
        self.isUpdatingPantry = isUpdatingPantry
        self.pendingKitchenwareIds = pendingKitchenwareIds
        self.pendingIngredientIds = pendingIngredientIds
        self.missingKitchenwareCount = missingKitchenwareCount
        self.missingIngredientCount = missingIngredientCount
        self.planItemAction = planItemAction
        self.kitchenwareItemAction = kitchenwareItemAction
        self.ingredientItemAction = ingredientItemAction
    }
    
    init(
        cookability: ChecklistCookability,
        _ isUpdatingPantry: Bool,
        _ pendingKitchenwareIds: Set<Int64>,
        _ pendingIngredientIds: Set<Int64>,
         _ planItemAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void,
         _ kitchenwareItemAction: @escaping (Int64, ChecklistKitchenwareAction) -> Void,
         _ ingredientItemAction: @escaping (Int64, ChecklistIngredientAction) -> Void)
    {
        self.cookability = cookability
        self.isUpdatingPantry = isUpdatingPantry
        self.pendingKitchenwareIds = pendingKitchenwareIds
        self.pendingIngredientIds = pendingIngredientIds
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
                VStack(spacing: 10) {
                    if !sortedKitchenwares.isEmpty {
                        kitchenwareList
                    }
                    
                    if !sortedIngredients.isEmpty {
                        ingredientList
                    }
                }
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
        VStack(spacing: 10) {
            HorizontalDivider()
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
                        ForEach(Array(sortedKitchenwares.enumerated()), id: \.element) { index, kitchenware in
                            ChecklistKitchenwareItem(
                                kitchenware,
                                disabled: isUpdatingPantry,
                                isLoading: pendingKitchenwareIds.contains(kitchenware.id),
                                action: kitchenwareItemAction)
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.horizontal, 10)
                    .animation(.default, value: sortedKitchenwares)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var ingredientList: some View {
        VStack(spacing: 10) {
            HorizontalDivider()
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
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .animation(.snappy, value: missingIngredientCount > 0)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .center, spacing: 10) {
                        ForEach(Array(sortedIngredients.enumerated()), id: \.element) { index, ingredient in
                            let isLast = index == (sortedIngredients.count - 1)
                            ChecklistIngredientItem(
                                ingredient,
                                disabled: isUpdatingPantry,
                                isLoading: pendingIngredientIds.contains(ingredient.id),
                                showDivider: !isLast,
                                action: ingredientItemAction)
                        }
                    }
                    .animation(.default, value: sortedIngredients)
                }
            }
            .padding(.vertical, 10)
        }
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
