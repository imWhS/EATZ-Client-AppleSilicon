//
//  ExploreKitchenwaresList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/6/25.
//

import SwiftUI

struct ExploreKitchenwaresList: View {
    let pagedKitchenwares: Paged<Kitchenware>
    let pagedSearchedKitchenwares: Paged<Kitchenware>
    @Binding var searchKeyword: String
    
    var searchState: ExploreKitchenwareListSearchState
    let onItemAction: (KitchenwareItemAction) -> Void
    @Binding var showNavigationBarTitle: Bool
    let onLoadMoreKitchenwares: () -> Void
    let onLoadMoreSearchedKitchenwares: () -> Void
    
    var body: some View {
        Group {
            if searchKeyword.isEmpty { normalStateView }
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
            case .searched: searchResultView
            case .error(let message): ErrorCurtain(message)
            case .empty:
                Curtain(
                    title: "원하는 도구가 없어요.",
                    description: "'\(searchKeyword)' 관련 도구를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요.")
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
    
    private var searchResultView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(pagedSearchedKitchenwares.items) { kitchenware in
                    KitchenwareItem(kitchenware, onAction: onItemAction)
                }
                if !pagedSearchedKitchenwares.isEmpty {
                    ListPageTailView(hasNextPage: pagedSearchedKitchenwares.hasNextPage, onAppearAction: onLoadMoreSearchedKitchenwares)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    private var normalStateView: some View {
        ScrollView {
            GeometryReader { proxy in
                let scrollYOffset = proxy.frame(in: .named("scroll")).minY
                Color.clear
                    .onChange(of: scrollYOffset) { _, scrollYOffset in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavigationBarTitle = scrollYOffset < -100
                        }
                    }
            }
            .frame(height: 0)
            VStack(spacing: 20) {
                normalStateHeader
                kitchenwareList
            }
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var normalStateHeader: some View {
        VStack(spacing: 8) {
            Text("도구 둘러보기")
                .font(.system(size: 30, weight: .bold))
            Text("모든 도구를 탐색하거나, 원하는 도구를 검색해보세요. 가지고 있는 도구를 보관함에 추가해보세요.")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
        }
        .padding(20)
    }
    
    private var kitchenwareList: some View {
        LazyVStack(spacing: 8) {
            ForEach(pagedKitchenwares.items) { kitchenware in
                KitchenwareItem(kitchenware, onAction: onItemAction)
            }
            if !pagedKitchenwares.isEmpty {
                ListPageTailView(hasNextPage: pagedKitchenwares.hasNextPage, onAppearAction: onLoadMoreKitchenwares)
            }
        }
    }
}
