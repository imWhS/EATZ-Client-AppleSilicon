//
//  ExploreView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import SwiftUI
import Kingfisher

/**
 RootTabView의 둘러보기 탭 최상위 뷰입니다.
 
 ExploreSearchBar의 인터랙션에 따라 아래 두 뷰 중 하나를 보여주는 컨테이너 뷰 역할을 합니다.
 1. ExploreRecipesView
    - 전체 레시피 목록입니다.
 2. ExploreSearchListView
    - 키워드로 검색한 레시피 목록입니다.
    - ExploreSearchBar를 통해 검색 모드를 활성화했거나, 키워드를 입력했을 때에만 보여집니다.
 */
struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @EnvironmentObject private var router: Router
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack(path: $router.path) {
            mainContent
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle("둘러보기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { DestinationView($0) }
        }
        .onChange(of: viewModel.navigationRoute) { _, navigationRoute in
            guard let route = navigationRoute else { return }
            router.push(route)
            viewModel.navigationRoute = nil
        }
        .sheet(item: $viewModel.sheet, content: buildSheet)
        .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private func buildSheet(for type: ExploreSheet) -> some View {
        switch type {
        case .tagsPicker:
            ThemePickerView(onComplete: { tagId in
                if let id = tagId {
                    viewModel.commonTag = ExploreTagItem(id: id, name: nil)
                    viewModel.loadTag(id: id)
                } else {
                    viewModel.commonTag = nil
                }
            })
        case .totalTimePicker:
            // 값 타입
            TotalTimePicker(totalTimeInMinutes: viewModel.commonFilters.totalTime ?? 0) { totalTime in
                var newFilters = viewModel.commonFilters
                newFilters.totalTime = totalTime
                viewModel.commonFilters = newFilters
            }
        case .servingsPicker:
            ServingsPicker(servings: viewModel.commonFilters.servings ?? 0) { servings in
                var newFilterOptions = viewModel.commonFilters
                newFilterOptions.servings = servings
                viewModel.commonFilters = newFilterOptions
            }
        case .plannerDatePicker(recipeId: let recipeId):
            PlannerDatePicker(for: recipeId)
        }
    }
    
    private var mainContent: some View {
        ZStack {
            if viewModel.isSearchMode {
                ExploreRecipeSearchView(
                    searchCriteriaPublisher: viewModel.searchCriteriaPublisher,
                    tag: $viewModel.commonTag,
                    filters: $viewModel.commonFilters,
                    sort: $viewModel.commonSort,
                    selectableSortOptions: viewModel.selectableSortOptions,
                    onFilter: { sheet in viewModel.sheet = sheet },
                    onTappedRecipe: viewModel.navigateToRecipe
                )
            } else {
                ExploreRecipesView(
                    tag: $viewModel.commonTag,
                    filters: $viewModel.commonFilters,
                    sort: $viewModel.commonSort,
                    selectableSortOptions: viewModel.selectableSortOptions,
                    onFilter: { Sheet in viewModel.sheet = Sheet },
                    onTappedRecipe: viewModel.navigateToRecipe
                )
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSearchMode)
        .safeAreaInset(edge: .top, spacing: 0) {
            ExploreSearchBar(
                keyword: $viewModel.keyword,
                isSearchMode: $viewModel.isSearchMode,
                theme: viewModel.commonTag,
                onShowThemePicker: { viewModel.sheet = .tagsPicker }
            )
        }
    }
}

#Preview {
    ExploreView()
}
