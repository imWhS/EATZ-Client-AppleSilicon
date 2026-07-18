//
//  SelectableIngredientList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

struct SelectableIngredientList<Manager: SelectableIngredientManager>: View {
    @EnvironmentObject private var manager: Manager
    
    let pagedIngredients: Paged<Ingredient>
    let pagedSearchedIngredients: Paged<Ingredient>
    
    @Binding var searchKeyword: String
    var searchState: SelectableIngredientSearchState
    
    let isItemSelected: (Ingredient) -> Bool
    let isItemDisabled: (Ingredient) -> Bool
    let onToggleSelection: (Ingredient) -> Void
    
    let onLoadMoreIngredients: () -> Void
    let onLoadMoreSearchedIngredients: () -> Void
    
    var body: some View {
        Group {
            if searchKeyword.isEmpty { ingredientList }
            else { searchStateView }
        }
        .background(Color.white)
        .searchable(text: $searchKeyword, prompt: "재료 이름으로 검색")
    }
    
    @ViewBuilder
    private var searchStateView: some View {
        switch searchState {
        case .searching: LoadingCurtain(title: "재료를 검색하고 있어요...")
        case .searched: searchedIngredientList
        case .error(let message): ErrorCurtain(message)
        case .empty:
            Curtain(
                title: "원하는 재료가 없어요.",
                description: "'\(searchKeyword)'와 관련있는 재료를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요."
            )
        }
    }
    
    private var searchedIngredientList: some View {
        ingredientList(
            listState: pagedSearchedIngredients,
            onLoadMore: onLoadMoreSearchedIngredients
        )
    }
    
    private var ingredientList: some View {
        ingredientList(
            listState: pagedIngredients,
            onLoadMore: onLoadMoreIngredients
        )
    }
    
    private func ingredientList(
        listState: Paged<Ingredient>,
        onLoadMore: @escaping () -> Void
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(listState.items) { ingredient in
                    SelectableIngredientItem<Manager>(
                        ingredient,
                        isSelected: isItemSelected(ingredient),
                        isDisabled: isItemDisabled(ingredient),
                        onToggleSelection: { onToggleSelection(ingredient) }
                    )
                    .environmentObject(manager)
                }
                if !listState.isEmpty {
                    ListPageTailView(hasNextPage: listState.hasNextPage, onAppearAction: onLoadMore)
                }
            }
        }
    }
}
