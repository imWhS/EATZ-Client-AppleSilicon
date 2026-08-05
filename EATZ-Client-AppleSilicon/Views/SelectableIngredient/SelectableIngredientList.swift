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
            if searchKeyword.isEmpty { allIngredientsView }
            else { searchStateView }
        }
        .background(Color.white)
        .searchable(text: $searchKeyword, prompt: "재료 이름으로 검색")
    }
    
    @ViewBuilder
    private var searchStateView: some View {
        VStack(spacing: 0) {
            searchResultHeader
            switch searchState {
            case .searching: LoadingCurtain(title: "재료를 찾고 있어요...")
            case .searched: searchedIngredientList
            case .error(let message): ErrorCurtain(message)
            case .empty:
                Curtain(
                    title: "원하는 재료가 없어요.",
                    description: "'\(searchKeyword)' 관련 재료를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요.",
                    header: {
                        Image("info-200")
                            .resizable()
                            .foregroundStyle(Color.gray15)
                            .frame(width: 40, height: 40)
                    }
                )
            }
        }
    }
    
    private var searchedIngredientList: some View {
        ScrollView {
            ingredientList(
                listState: pagedSearchedIngredients,
                onLoadMore: onLoadMoreSearchedIngredients
            )
        }
    }
    
    private var allIngredientsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("모든 재료")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray35)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                ingredientList(
                    listState: pagedIngredients,
                    onLoadMore: onLoadMoreIngredients
                )
            }
        }
    }
    
    private var searchSubtitleLabel: String {
        if searchKeyword.isEmpty {
            return ""
        } else {
            return "'\(searchKeyword)' 관련 재료"
        }
    }
    
    private var searchResultHeader: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("재료 검색")
                    .font(.system(size: 17, weight: .semibold))
                Text(searchSubtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            .padding(20)
            HorizontalDivider()
        }
    }
    
    private func ingredientList(
        listState: Paged<Ingredient>,
        onLoadMore: @escaping () -> Void
    ) -> some View {
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
        .padding(.vertical, 16)
    }
}
