//
//  ExploreRecipesView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI
import Kingfisher

struct ExploreRecipesView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ExploreRecipesViewModel()
    
    @Binding var tag: ExploreTagItem?
    @Binding var filters: ExploreFilters
    @Binding var sort: ExploreRecipesSort
    
    var selectableSortOptions: [ExploreRecipesSort]
    var onFilter: (ExploreSheet) -> Void
    var onTappedRecipe: (ExploreRecipe) -> Void
    
    init(
        tag: Binding<ExploreTagItem?>,
        filters: Binding<ExploreFilters>,
        sort: Binding<ExploreRecipesSort>,
        selectableSortOptions: [ExploreRecipesSort],
        onFilter: @escaping (ExploreSheet) -> Void,
        onTappedRecipe: @escaping (ExploreRecipe) -> Void
    ) {
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
            .task(id: filters) { viewModel.updateListOptions(newFilters: filters, newSort: sort) }
            .task(id: sort) { viewModel.updateListOptions(newFilters: filters, newSort: sort) }
            .task(id: authManager.currentUser) { viewModel.prepareDataIfNeeded() }
            .onChange(of: viewModel.navigationRoute) { _, navigationRoute in
                guard let route = navigationRoute else { return }
                router.push(route)
                viewModel.navigationRoute = nil }
            .alert(item: $viewModel.alert) { $0.alert }
            .sheet(item: $viewModel.sheet) { item in
                switch item {
                case .addToPlanner(let recipeId):
                    PlannerDatePicker(for: recipeId)
                }}
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private var rootView: some View {
        VStack(spacing: 0) {
            switch viewModel.viewState {
            case .loaded: ScrollView { stateView }
            default: stateView
            }
        }
        .background(Color.backgroundPrimary)
    }
    
    @ViewBuilder
    private var stateView: some View {
        ExploreFiltersSection(filters, onAction: onFilter)
        
        switch viewModel.viewState {
        case .initialLoading: LoadingCurtain(title: "\(tag?.name ?? "모든") 레시피를 불러오고 있어요...")
        case .loaded:
            ExploreRecipeGridList(
                pagedRecipes: viewModel.pagedRecipes,
                onTappedRecipe: onTappedRecipe,
                onTappedItemAction: viewModel.handleItem,
                onLoadMore: viewModel.loadMoreRecipes,
                selectableSortOptions: selectableSortOptions,
                sort: $sort)
        case .empty:
            Curtain(
                title: "보여드릴 레시피가 없어요.",
                description: "카테고리나 필터 옵션을 변경해보세요.",
                header: {
                    Image("info-200")
                        .resizable()
                        .foregroundStyle(Color.gray15)
                        .frame(width: 40, height: 40)
                }
            )
        case .error(let message): ErrorCurtain(message, onRetry: viewModel.resetAndLoadAll)
        }
    }
}
