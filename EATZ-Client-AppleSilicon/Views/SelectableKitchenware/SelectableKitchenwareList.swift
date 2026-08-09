//
//  KitchenwareListSelectionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

struct SelectableKitchenwareList<Manager: SelectableKitchenwareManager>: View {
    let pagedKitchenwares: Paged<Kitchenware>
    let pagedSearchedKitchenwares: Paged<Kitchenware>
    
    @Binding var searchKeyword: String
    var searchState: SelectableKitchenwareSearchState
    
    let isItemSelected: (Kitchenware) -> Bool
    let isItemDisabled: (Kitchenware) -> Bool
    let onToggleSelection: (Kitchenware) -> Void
    
    let loadMoreKitchenwares: () -> Void
    let loadMoreSearchedKitchenwares: () -> Void
    
    @EnvironmentObject private var manager: Manager
    
    var body: some View {
        Group {
            if searchKeyword.isEmpty { allKitchenwaresView }
            else { searchStateView }
        }
        .background(Color.white)
        .searchable(text: $searchKeyword, prompt: "도구 이름으로 검색")
    }
    
    @ViewBuilder
    private var searchStateView: some View {
        VStack(spacing: 0) {
            searchResultHeader
            switch searchState {
            case .searching: LoadingCurtain(title: "도구를 찾고 있어요...")
            case .searched: searchedKitchenwareList
            case .error(let message): ErrorCurtain(message)
            case .empty:
                CommonEmptyStateView(
                    title: "원하는 도구가 없어요.",
                    "'\(searchKeyword)' 관련 도구를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요."
                )
            }
        }
    }
    
    private var searchedKitchenwareList: some View {
        ScrollView {
            kitchenwareList(pagedKitchenwares: pagedSearchedKitchenwares, loadMoreKitchenwares: loadMoreSearchedKitchenwares)
        }
    }
    
    private var allKitchenwaresView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("모든 도구")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray35)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                kitchenwareList(pagedKitchenwares: pagedKitchenwares, loadMoreKitchenwares: loadMoreKitchenwares)
            }
        }
    }
    
    private var searchSubtitleLabel: String {
        if searchKeyword.isEmpty {
            return ""
        } else {
            return "'\(searchKeyword)' 관련 도구"
        }
    }
    
    private var searchResultHeader: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("도구 검색")
                    .font(.system(size: 17, weight: .semibold))
                Text(searchSubtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            .padding(20)
            HorizontalDivider()
        }
    }
    
    private func kitchenwareList(pagedKitchenwares: Paged<Kitchenware>, loadMoreKitchenwares: @escaping () -> Void) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(pagedKitchenwares.items) { kitchenware in
                SelectableKitchenwareItem<Manager>(
                    kitchenware,
                    isSelected: isItemSelected(kitchenware),
                    isDisabled: isItemDisabled(kitchenware),
                    onToggleSelection: { onToggleSelection(kitchenware) }
                )
            }
            if !pagedKitchenwares.isEmpty {
                ListPageTailView(hasNextPage: pagedKitchenwares.hasNextPage, onAppear: loadMoreKitchenwares)
            }
        }
        .padding(.vertical, 16)
    }
}
