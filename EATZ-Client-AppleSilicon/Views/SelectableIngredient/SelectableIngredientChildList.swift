//
//  SelectableIngredientChildList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import SwiftUI

struct SelectableIngredientChildList<Manager: SelectableIngredientManager>: View {
    let parentId: Int64
    let parentName: String
    
    @StateObject private var viewModel: SelectableIngredientChildListViewModel
    @EnvironmentObject private var manager: Manager
    @Environment(\.dismiss) private var dismiss
    
    init(parentId: Int64, parentName: String) {
        self.parentId = parentId
        self.parentName = parentName
        _viewModel = StateObject(wrappedValue: SelectableIngredientChildListViewModel(parentId: parentId))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.childIngredients) { childIngredient in
                    SelectableIngredientItem<Manager>(
                        childIngredient,
                        isSelected: manager.isSelected(childIngredient.id),
                        isDisabled: manager.isDisabled(childIngredient),
                        onToggleSelection: { manager.toggleSelection(for: childIngredient) }
                    )
                }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .navigationTitle(parentName)
        .toolbar { doneToolbarItem }
        .task { viewModel.loadChildIngredients() }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("완료", action: { manager.complete() })
                .fontWeight(.semibold)
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
        }
    }
}
