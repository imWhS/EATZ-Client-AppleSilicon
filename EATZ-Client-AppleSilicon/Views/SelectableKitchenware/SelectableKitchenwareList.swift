//
//  KitchenwareListSelectionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

struct SelectableKitchenwareList<Manager: SelectableKitchenwareManager>: View {
    let kitchenwares: [Kitchenware]
    let searchedKitchenwares: [Kitchenware]
    
    @Binding var searchKeyword: String
    var searchState: SelectableKitchenwareSearchState
    
    let isItemSelected: (Kitchenware) -> Bool
    let isItemDisabled: (Kitchenware) -> Bool
    let onToggleSelection: (Kitchenware) -> Void
    
    @EnvironmentObject private var manager: Manager
    
    var body: some View {
        Group {
            if searchKeyword.isEmpty { kitchenwareList }
            else { searchStateView }
        }
        .background(Color.white)
        .searchable(text: $searchKeyword, prompt: "도구 이름으로 검색")
    }
    
    @ViewBuilder
    private var searchStateView: some View {
        switch searchState {
        case .searching: LoadingCurtain(title: "도구를 검색하고 있어요...")
        case .searched: searchedKitchenwareList
        case .error(let message): ErrorCurtain(message)
        case .empty:
            Curtain(
                title: "원하는 도구가 없어요.",
                description: "'\(searchKeyword)'와 관련있는 도구를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요."
            )
        }
    }
    
    private var searchedKitchenwareList: some View {
        ingredientList(kitchenwares: searchedKitchenwares)
    }
    
    private var kitchenwareList: some View {
        ingredientList(kitchenwares: kitchenwares)
    }
    
    private func ingredientList(kitchenwares: [Kitchenware]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(kitchenwares) { kitchenware in
                    SelectableKitchenwareItem<Manager>(
                        kitchenware,
                        isSelected: isItemSelected(kitchenware),
                        isDisabled: isItemDisabled(kitchenware),
                        onToggleSelection: { onToggleSelection(kitchenware) }
                    )
                }
//                if !listState.isEmpty {
//                    ListPageTailView(hasNextPage: listState.hasNextPage, onAppearAction: onLoadMore)
//                }
            }
        }
    }
}
