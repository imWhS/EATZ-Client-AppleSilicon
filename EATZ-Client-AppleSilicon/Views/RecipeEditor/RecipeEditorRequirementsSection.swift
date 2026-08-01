//
//  RecipeEditorRequirementsSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI

struct RecipeEditorRequirementsSection: View {
    @Binding var draft: RecipeDraft
    let onShowKitchenwarePicker: () -> Void
    let onShowIngredientPicker: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                RecipeEditorSectionHeaderView(title: "준비물", description: "레시피를 요리하기 위해 준비해야 할 항목을 추가해보세요.")
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            RecipeEditorAddActionButton(text: "도구 추가", onAdd: onShowKitchenwarePicker)
                            RecipeEditorAddActionButton(text: "재료 추가", onAdd: onShowIngredientPicker)
                        }
                    }
                    .padding(.horizontal, 20)
                    if !draft.kitchenwares.isEmpty {
                        VStack(spacing: 20) {
                            HStack {
                                VerticalLabeledValueView(
                                    label: "총 도구 수",
                                    value: "\(draft.kitchenwares.count)개",
                                    style: .secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(draft.kitchenwares, id: \.id) { kitchenware in
                                        SelectedKitchenwareItem(name: kitchenware.name, imageUrl: kitchenware.imageUrl, isFullWidth: false, onDeselect: { draft.kitchenwares.removeAll { $0.id == kitchenware.id } })
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
                    }
                    // 추가된 재료 목록
                    if !draft.ingredients.isEmpty {
                        VStack(spacing: 20) {
                            HStack {
                                VerticalLabeledValueView(
                                    label: "총 재료 수",
                                    value: "\(draft.ingredients.count)개",
                                    style: .secondary)
//                                Text("재료")
//                                    .font(.system(size: 12, weight: .semibold))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack {
                                ForEach(draft.ingredients, id: \.id) { ingredient in
                                    SelectedIngredientItem(
                                        parentCoupled: ingredient.parentCoupled,
                                        coupledParentName: ingredient.coupledParentName,
                                        name: ingredient.name,
                                        isFullWidth: true,
                                        onDeselect: { draft.ingredients.removeAll { $0.id == ingredient.id } }
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
            }
            HorizontalDivider()
        }
    }
}
