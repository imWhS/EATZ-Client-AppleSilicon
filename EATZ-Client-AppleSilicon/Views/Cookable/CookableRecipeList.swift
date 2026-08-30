//
//  CookableRecipeList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/4/25.
//

import SwiftUI

struct CookableRecipeList: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var router: Router
    
    @StateObject private var viewModel: CookableRecipeListViewModel
    
    private var isEmptyList: Bool { viewModel.pagedRecipes.isEmpty }
    
    private var listHeaderTitleLabel: String {
        let totalElements = viewModel.pagedRecipes.totalElements
        if isEmptyList {
            return "요리할만한 레시피를\n찾을 수 없어요."
        } else {
            return "요리할만한 레시피를\n\(totalElements)개 찾았어요."
        }
    }
    
    private var emptyViewSubtitleLabel: String {
        if authManager.isLoggedIn && viewModel.searchCriteria.isCookableOnly {
            return "'바로 요리 가능' 옵션을 해제하거나, 이전 화면으로 돌아가서 키워드나 옵션을 바꾼 후 다시 시도해보세요."
        } else {
            return "이전 화면으로 돌아가서 키워드나 옵션을 바꾼 후 다시 시도해보세요."
        }
    }
    
    init(searchCriteria: CookableSearchCriteria) {
        self._viewModel = StateObject(wrappedValue: CookableRecipeListViewModel(searchCriteria: searchCriteria))
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
            case .error(let message): ErrorCurtain(message, onRetryTapped: viewModel.resetAndLoadAll).transition(.opacity)
            case .empty: emptyStateView
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.navigationTitleLabel)
        .toolbar { titleToolbarItem }
    }
    
    private var emptyStateView: some View {
        VStack {
            listHeader
            VStack(spacing: 4) {
                Spacer()
                VStack(spacing: 12) {
                    Image("info-200")
                        .resizable()
                        .foregroundStyle(Color.gray15)
                        .frame(width: 40, height: 40)
                    VStack(spacing: 4) {
                        Text("설정하신 옵션과 상황에 맞는 레시피를 하나도 찾지 못했어요.")
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray35)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(emptyViewSubtitleLabel)
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray35)
                    }
                }
                Spacer()
                VStack(spacing: 8) {
                    if authManager.isLoggedIn && viewModel.searchCriteria.isCookableOnly == true {
                        Button(action: { viewModel.searchCriteria.isCookableOnly = false }) {
                            Text("'바로 요리 가능' 해제")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(RoundedButtonStyle(.secondary, .large))
                    }
                    Button(action: { router.popToRoot() }) {
                        HStack {
                            Image("arrow-left-14")
                            Text("이전 화면으로 이동")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(.secondary, .large))
                }
                .transition(.opacity)
            }
            .padding(20)
            .animation(.easeInOut(duration: 0.3), value: viewModel.searchCriteria.isCookableOnly)
        }
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
                            authManager.isLoggedIn,
                            onTappedRecipe: { id in router.push(.recipe(id: id)) },
                            action: viewModel.handleRecipeAction)
                    }
                    ListPageTailView(hasNextPage: viewModel.pagedRecipes.hasNextPage, onAppear: viewModel.loadMoreRecipes)
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.pagedRecipes.items)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var listHeaderTitleText: some View {
        Text(listHeaderTitleLabel)
            .font(.system(size: 30, weight: .bold))
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
    
    private var listHeader: some View {
        VStack(spacing: 0) {
            listHeaderTitleText
            
            HStack(spacing: 0) {
                CookableRecipeListToggle(
                    isCookableOnly: $viewModel.searchCriteria.isCookableOnly,
                    isEnabled: authManager.isLoggedIn)
                Spacer()
                SortPicker(
                    sort: $viewModel.sort,
                    selectableSorts: viewModel.selectableSortOptions,
                    isDisabled: isEmptyList)
            }
            .padding(.leading, 20)
            .padding(.vertical, 10)
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(viewModel.navigationTitleLabel)
                    .font(.system(size: 17, weight: .semibold))
                Text(viewModel.navigationSubtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
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

#Preview {
    CookableRecipeList(
        searchCriteria: CookableSearchCriteria(keyword: "테스트", maxTotalTime: 10, servings: 1, isCookableOnly: true)
    )
}

