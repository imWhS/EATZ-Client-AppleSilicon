//
//  ExploreRecipeSearchView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI
import Kingfisher
import Combine

struct ExploreRecipeSearchView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: ExploreRecipeSearchViewModel
    
    @Binding var tag: ExploreTagItem?
    @Binding var filters: ExploreFilters
    @Binding var sort: ExploreRecipesSort
    
    var selectableSortOptions: [ExploreRecipesSort]
    var onFilter: (ExploreSheet) -> Void
    var onTappedRecipe: (ExploreRecipe) -> Void
    
    
    init(
        searchCriteriaPublisher: AnyPublisher<
            (String, ExploreFilters, ExploreRecipesSort), Never>,
        tag: Binding<ExploreTagItem?>,
        filters: Binding<ExploreFilters>,
        sort: Binding<ExploreRecipesSort>,
        selectableSortOptions: [ExploreRecipesSort],
        onFilter: @escaping (ExploreSheet) -> Void,
        onTappedRecipe: @escaping (ExploreRecipe) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: ExploreRecipeSearchViewModel(searchCriteriaPublisher: searchCriteriaPublisher))
        self._tag = tag
        self._filters = filters
        self._sort = sort
        self.selectableSortOptions = selectableSortOptions
        self.onFilter = onFilter
        self.onTappedRecipe = onTappedRecipe
    }
    
    var body: some View {
        rootView
            .refreshable { await viewModel.refresh() }
            .task(id: authManager.currentUser) { viewModel.prepareDataIfNeeded() }
            .onChange(of: viewModel.navigationRoute) { _, navigationRoute in
                guard let route = navigationRoute else { return }
                router.push(route)
                viewModel.navigationRoute = nil
            }
            .alert(item: $viewModel.alert) { $0.alert }
            .sheet(item: $viewModel.sheet) { item in
                switch item {
                case .addToPlanner(let recipeId):
                    PlannerDatePicker(for: recipeId)
                }
            }
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private var rootView: some View {
        VStack(spacing: 0) {
            switch viewModel.viewState {
            case .idle:
                ExploreFiltersSection(filters, onAction: onFilter)
                Curtain(
                    title: "\(tag?.name ?? "모든") 레시피 목록에서 검색",
                    description: "원하는 레시피의 키워드를 입력하세요.",
                    header: {
                        Image("search-200")
                            .resizable()
                            .foregroundStyle(Color.gray15)
                            .frame(width: 40, height: 40)
                    }
                )
                .transition(.opacity)
            case .initialLoading:
                ExploreFiltersSection(filters, onAction: onFilter)
                LoadingCurtain(title: "레시피를 찾고 있어요...")
                    .transition(.opacity)
            case .loaded:
                ScrollView {
                    ExploreFiltersSection(filters, onAction: onFilter)
                    ExploreRecipeGridList(
                        pagedRecipes: viewModel.pagedRecipes,
                        onTappedRecipe: onTappedRecipe,
                        onTappedItemAction: viewModel.handleItem,
                        loadMore: viewModel.loadMoreRecipes,
                        selectableSortOptions: selectableSortOptions,
                        sort: $sort)
                    .transition(.opacity)
                }
            case .empty(let keyword):
                ExploreFiltersSection(filters, onAction: onFilter)
                CommonEmptyStateView(
                    title: "원하는 레시피가 없어요.",
                    "'\(keyword)' 관련 레시피를 하나도 찾지 못했어요.\n다른 검색어를 사용하거나, 필터 옵션을 변경해보세요.")
                .transition(.opacity)
            case .error(let message):
                ExploreFiltersSection(filters, onAction: onFilter)
                ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded)
                    .transition(.opacity)
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
    }
    
    @ViewBuilder
    private var stateView: some View {
        VStack(spacing: 0) {
            ExploreFiltersSection(filters, onAction: onFilter)
            
            switch viewModel.viewState {
            case .idle:
                Curtain(
                    title: "\(tag?.name ?? "모든") 레시피 목록에서 검색",
                    description: "원하는 레시피의 키워드를 입력하세요.",
                    header: {
                        Image("search-200")
                            .resizable()
                            .foregroundStyle(Color.gray15)
                            .frame(width: 40, height: 40)
                    }
                )
                .transition(.opacity)
            case .initialLoading:
                LoadingCurtain(title: "레시피를 찾고 있어요...")
                    .transition(.opacity)
            case .loaded:
                ExploreRecipeGridList(
                    pagedRecipes: viewModel.pagedRecipes,
                    onTappedRecipe: onTappedRecipe,
                    onTappedItemAction: viewModel.handleItem,
                    loadMore: viewModel.loadMoreRecipes,
                    selectableSortOptions: selectableSortOptions,
                    sort: $sort)
                .transition(.opacity)
            case .empty(let keyword):
                CommonEmptyStateView(
                    title: "원하는 레시피가 없어요.",
                    "'\(keyword)' 관련 레시피를 하나도 찾지 못했어요.\n다른 검색어를 사용하거나, 필터 옵션을 변경해보세요.")
                .transition(.opacity)
            case .error(let message):
                ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
    }
}
