//
//  ExploreIngredientsList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/6/25.
//

import SwiftUI

struct ExploreIngredientsList: View {
    @EnvironmentObject var viewModel: ExploreIngredientsViewModel
    
    var searchState: ExploreIngredientListSearchState { viewModel.searchState }
    
    var pagedIngredients: Paged<Ingredient> { viewModel.pagedIngredients }
    var pagedSearchedIngredients: Paged<Ingredient> { viewModel.pagedSearchedIngredients }
    
    var body: some View {
        Group {
            if viewModel.searchKeyword.isEmpty { normalStateView }
            else { searchStateView }
        }
        .background(Color.white)
        .searchable(text: $viewModel.searchKeyword, prompt: "재료 이름으로 검색")
    }
    
    @ViewBuilder
    private var searchStateView: some View {
        VStack(spacing: 0) {
            searchResultHeader
            switch searchState {
            case .searching: LoadingCurtain(title: "재료를 찾고 있어요...")
            case .searched: searchResultView
            case .error(let message): ErrorCurtain(message)
            case .empty:
                Curtain(
                    title: "원하는 재료가 없어요.",
                    description: "'\(viewModel.searchKeyword)' 관련 재료를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요.",
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
    
    private var searchSubtitleLabel: String {
        if viewModel.searchKeyword.isEmpty {
            return ""
        } else {
            return "'\(viewModel.searchKeyword)' 관련 재료"
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
    
    private var searchResultView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(pagedSearchedIngredients.items) { ingredient in
                    IngredientItem(
                        ingredient,
                        isLinkable: true,
                        linkDestination: ExploreIngredientsChildList(parentId: ingredient.id, parentName: ingredient.name),
                        onAction: viewModel.handleItemAction)
                }
                if !pagedSearchedIngredients.isEmpty {
                    ListPageTailView(hasNextPage: pagedSearchedIngredients.hasNextPage, onAppearAction: viewModel.loadMoreSearchedIngredients)
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
                            viewModel.showNavigationBarTitle = scrollYOffset < -100
                        }
                    }
            }
            .frame(height: 0)
            VStack(spacing: 20) {
                normalStateHeader
                ingredientList
            }
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var normalStateHeader: some View {
        VStack(spacing: 8) {
            Text("재료 둘러보기")
                .font(.system(size: 30, weight: .bold))
            Text("재료 및 하위 재료를 탐색하거나, 원하는 재료를 검색해보세요. 자주 찾는 재료에 좋아요를 표시하고, 가지고 있는 재료를 보관함에 추가해보세요.")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
        }
        .padding(20)
    }
    
    private var ingredientList: some View {
        LazyVStack(spacing: 8) {
            ForEach(pagedIngredients.items) { ingredient in
                IngredientItem(ingredient,
                               isLinkable: true,
                               linkDestination: ExploreIngredientsChildList(
                                parentId: ingredient.id, parentName: ingredient.name),
                               onAction: viewModel.handleItemAction)
            }
            if !pagedIngredients.isEmpty {
                ListPageTailView(hasNextPage: pagedIngredients.hasNextPage, onAppearAction: viewModel.loadMoreIngredients)
            }
        }
    }
}
