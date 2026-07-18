//
//  IngredientAdditionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/3/25.
//

import SwiftUI

struct IngredientAdditionView: View {
    @StateObject private var viewModel = IngredientAdditionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        viewStateContent
        .alert(item: $viewModel.alert) { $0.alert }
        .onAppear {
            viewModel.setDismissAction(dismiss.callAsFunction)
            viewModel.prepareDataIfNeeded()
        }
    }
    
    private var viewStateContent: some View {
        VStack {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "재료 목록을 불러오고 있어요...")
            case .loaded: mainContentView
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message)
            case .empty: Curtain(title: "보여드릴재료가 없어요.")
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            NavigationStack {
                SelectableIngredientList<IngredientAdditionViewModel>(
                        pagedIngredients: viewModel.pagedIngredients,
                        pagedSearchedIngredients: viewModel.pagedSearchedIngredients,
                        searchKeyword: $viewModel.searchKeyword,
                        searchState: viewModel.searchState,
                        isItemSelected: { ingredient in viewModel.isSelected(ingredient.id) },
                        isItemDisabled: { ingredient in ingredient.ownedByUser },
                        onToggleSelection: viewModel.toggleSelection,
                        onLoadMoreIngredients: viewModel.loadMoreIngredients,
                        onLoadMoreSearchedIngredients: viewModel.loadMoreSearchedIngredients
                )
                .environmentObject(viewModel)
                .navigationTitle("재료")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    dismissToolbarItem
                    doneToolbarItem
                }
            }
            SelectedIngredientBar(
                ingredients: viewModel.selectedIngredients,
                onDeselectIngredient: viewModel.toggleSelection,
                placeholder: "목록에서 보관함에 추가할 재료를 선택하거나,\n원하는 재료 이름으로 검색해서 보관함에 추가할 재료를 선택하세요.")
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("완료", action: { viewModel.complete() })
                .fontWeight(.semibold)
                .disabled(viewModel.selectedIngredients.isEmpty)
        }
    }
}

#Preview {
    IngredientAdditionView()
}
