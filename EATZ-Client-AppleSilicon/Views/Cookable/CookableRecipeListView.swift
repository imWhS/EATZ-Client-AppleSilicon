//
//  CookableRecipeListView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/4/25.
//

import SwiftUI

struct CookableRecipeListView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var router: Router
    
    @StateObject private var viewModel: CookableRecipeListViewModel
    
    init(searchCriteria: CookableSearchCriteria) {
        _viewModel = StateObject(wrappedValue: CookableRecipeListViewModel(searchCriteria: searchCriteria))
    }
    
    var body: some View {
        mainContent
            .refreshable { await viewModel.refresh() }
            .task(id: authManager.currentUser) { viewModel.prepareDataIfNeeded() }
            .alert(item: $viewModel.alert) { $0.alert }
            .sheet(item: $viewModel.sheet) { item in
                switch item {
                case .addToPlanner(let recipeId): PlannerDatePicker(for: recipeId) {}
                }
            }
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            switch viewModel.viewState {
            case .initialLoading: LoadingCurtain(title: "요리할 수 있는 레시피 목록을 불러오고 있어요...").transition(.opacity)
            case .loaded: listContainer.transition(.opacity)
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.resetAndLoadAll).transition(.opacity)
            case .empty:
                Curtain(
                    title: "지금 요리할 수 있는 레시피가 없어요.",
                    description: "이전 화면으로 돌아가서, 키워드나 옵션을 바꾼 후 다시 시도해보세요.").transition(.opacity)
            }
        }
        .background(Color.backgroundPrimary)
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { titleToolbarItem }
    }
    
    private var listContainer: some View {
        ScrollView {
            VStack(spacing: 0) {
                scrollTrackingGeometryReader
                listHeader
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.pagedRecipes.items) { recipe in
                        CookableRecipeItem(
                            recipe,
                            onTapItem: { id in router.push(.recipe(id: id)) },
                            onAction: viewModel.handleRecipeAction)
                    }
                    ListPageTailView(hasNextPage: viewModel.pagedRecipes.hasNextPage, onAppearAction: viewModel.loadMoreRecipes)
                }
                .animation(.default, value: viewModel.pagedRecipes.items)
            }
            .padding(.vertical, 10)
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var listHeader: some View {
        VStack(spacing: 0) {
            Text("지금, 요리할 수 있는\n\(viewModel.pagedRecipes.totalElements)개의 레시피")
                .font(.system(size: 26, weight: .bold))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            
            HStack(spacing: 0) {
                CookableRecipeListToggleButton(
                    isCookableOnly: $viewModel.searchCriteria.isCookableOnly,
                    isEnabled: authManager.isLoggedIn
                )
                Spacer()
                SortPicker(
                    sort: $viewModel.sort,
                    selectableSorts: viewModel.selectableSortOptions,
                    isDisabled: viewModel.pagedRecipes.isEmpty)
            }
            .padding(.leading, 20)
            .padding(.vertical, 10)
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("\(viewModel.pagedRecipes.totalElements)개의 레시피")
                .font(.headline)
                .opacity(viewModel.showNavigationBarTitle ? 1 : 0)
        }
    }
    
    private var scrollTrackingGeometryReader: some View {
        GeometryReader { proxy in
            let scrollYOffset = proxy.frame(in: .named("scroll")).minY
            Color.clear
                .onChange(of: scrollYOffset) { _, offset in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showNavigationBarTitle = offset < -100
                    }
                }
        }
        .frame(height: 0)
    }
}

private struct CookableRecipeListToggleButton: View {
    @Binding var isCookableOnly: Bool
    var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Button(action: {
                isCookableOnly.toggle()
            }) {
                CheckToggleCircled(isToggled: isCookableOnly)
            }
            Text("요리 가능")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.black)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.2)
    }
}

#Preview {
    CookableRecipeListView(
        searchCriteria: CookableSearchCriteria(keyword: "테스트", maxTotalTime: 10, servings: 1, isCookableOnly: true)
    )
}

