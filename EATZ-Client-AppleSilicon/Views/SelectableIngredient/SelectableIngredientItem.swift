//
//  SelectableIngredientItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/21/25.
//

import SwiftUI

struct SelectableIngredientItem<Manager: SelectableIngredientManager>: View {
    @EnvironmentObject private var manager: Manager
    
    let ingredient: Ingredient
    let isSelected: Bool
    let isDisabled: Bool
    var onToggleSelection: () -> Void
    
    init(_ ingredient: Ingredient,
         isSelected: Bool,
         isDisabled: Bool,
         onToggleSelection: @escaping () -> Void) {
        self.ingredient = ingredient
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.onToggleSelection = onToggleSelection
    }

    var body: some View {
        IngredientRow(ingredient,
                      isLinkable: true,
                      linkDestination: SelectableIngredientChildList<Manager>(
                        parentId: ingredient.id, parentName: ingredient.name).environmentObject(manager),
                      trailing: trailing)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    private func trailing() -> some View {
        HStack(spacing: 0) {
            VerticalDivider(padding: 8)
            HStack(spacing: 0) {
                if isDisabled { pantryStatusText }
                else { toggleSelectionButton }
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)
        }
    }
    
    private var pantryStatusText: some View {
        Text("보관 중")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.gray35)
            .frame(height: 32)
            .padding(.leading, 4)
            .padding(.trailing, 8)
    }
    
    private var toggleSelectionButton: some View {
        Button(action: onToggleSelection) {
            HStack(spacing: 6) {
                Image("check-12")
                if isSelected { Text("취소") }
                else { Text("선택") }
            }
        }
        .buttonStyle(RoundedButtonStyle(isDisabled ? .disabled : (isSelected ? .secondary : .primary), .medium))
    }
}
