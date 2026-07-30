//
//  IngredientPicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import SwiftUI

struct IngredientPicker: View {
    @StateObject private var viewModel: IngredientPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(initialSelection: Binding<[IngredientEssential]>) {
        _viewModel = StateObject(wrappedValue: IngredientPickerViewModel(initialSelection: initialSelection))
    }
    
    var body: some View {
        viewStateContent
            .task {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
            .alert(item: $viewModel.alert) { $0.alert }
    }
    
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "재료 목록을 불러오고 있어요...")
            case .loaded: mainContentView
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .empty: Curtain(title: "보여드릴 재료가 없어요.")
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            NavigationStack {
                SelectableIngredientList<IngredientPickerViewModel>(
                        pagedIngredients: viewModel.pagedIngredients,
                        pagedSearchedIngredients: viewModel.pagedSearchedIngredients,
                        searchKeyword: $viewModel.searchKeyword,
                        searchState: viewModel.searchState,
                        isItemSelected: { item in viewModel.isSelected(item.id) },
                        isItemDisabled: { _ in false },
                        onToggleSelection: viewModel.toggleSelection,
                        onLoadMoreIngredients: viewModel.loadMoreIngredients,
                        onLoadMoreSearchedIngredients: viewModel.loadMoreSearchedIngredients
                )
                .navigationTitle("재료")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    dismissToolbarItem
                    doneToolbarItem
                }
            }
            .environmentObject(viewModel)
            SelectedIngredientBar(
                ingredients: viewModel.selectedIngredients,
                onDeselectIngredient: viewModel.toggleSelection,
                placeholder: "목록에서 레시피에 추가할 재료를 선택하거나,\n원하는 재료 이름으로 검색해서 레시피에 추가할 재료를 선택하세요.")
        }
        .background(Color.backgroundPrimary)
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
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
        }
    }
}
