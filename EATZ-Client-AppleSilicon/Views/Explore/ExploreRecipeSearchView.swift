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
        onTappedRecipe: @escaping (ExploreRecipe) -> Void,
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
        VStack {
            switch viewModel.viewState {
            case .loaded:
                ScrollView {
                    stateView
                }
            default: stateView
            }
        }
        .background(Color.backgroundPrimary)
    }
    
    @ViewBuilder
    private var stateView: some View {
        ExploreFilterView(filters: filters, onAction: onFilter)
        
        switch viewModel.viewState {
        case .idle: idleView
        case .initialLoading: LoadingCurtain(title: "레시피를 검색하고 있어요...")
        case .loaded:
            ExploreRecipeGridList(
                pagedRecipes: viewModel.pagedRecipes,
                onTappedRecipe: onTappedRecipe,
                onTappedItemAction: viewModel.handleItem,
                onLoadMore: viewModel.loadMoreRecipes,
                selectableSortOptions: selectableSortOptions,
                sort: $sort)
        case .empty(let keyword):
            Curtain(
                title: "원하는 레시피가 없어요.",
                description: "'\(keyword)'에 해당하는 레시피를 하나도 찾지 못했어요.\n다른 검색어를 사용하거나, 필터 옵션을 변경해보세요."
            )
        case .error(let message):
            ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
        }
    }
    
    @ViewBuilder
    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 4) {
                Text("\(tag?.name ?? "모든") 레시피 목록에서 검색")
                    .font(.system(size: 17, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "8B8B8B"))
                    .fixedSize(horizontal: false, vertical: true)
                Text("검색어를 입력해보세요.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            Spacer()
        }
    }
}
