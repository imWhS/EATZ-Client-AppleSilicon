//
//  PlannerRecipePicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/19/25.
//

import SwiftUI

/// 원하는 레시피를 선택해, 해당 레시피를 플래너의 특정 날짜에 플랜으로 추가하는 뷰입니다.
struct PlannerRecipePicker: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlannerRecipePickerViewModel
    @FocusState private var isSearchFieldFocused: Bool
    
    private let onComplete: (() -> Void)?
    private let disabledRecipeIds: Set<Int64>
    
    init(
        _ date: Date,
        onComplete: (() -> Void)? = nil,
        disabledRecipeIds: Set<Int64> = []) {
        self._viewModel = StateObject(wrappedValue: PlannerRecipePickerViewModel(date: date))
        self.onComplete = onComplete
        self.disabledRecipeIds = disabledRecipeIds
    }
    
    var body: some View {
        NavigationStack {
            viewStateContent
                .navigationTitle("플래너에 추가")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { dismissToolbarItem }
        }
        .task {
            viewModel.setActions(dismissAction: dismiss.callAsFunction, completeAction: onComplete ?? {})
            viewModel.prepareDataIfNeeded()
        }
        .onChange(of: isSearchFieldFocused) { _, isSearchFieldFocused in
            if isSearchFieldFocused { viewModel.startSearch() }
        }
        .alert(item: $viewModel.alert) { $0.alert }
    }
    
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .idle: mainContent
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            }
        }
    }
    
    private var mainContent: some View {
        ZStack {
            VStack(spacing: 0) {
                EssentialRecipeSearchBar(
                    keyword: $viewModel.keyword,
                    isFocused: $isSearchFieldFocused,
                    style: .normal,
                    onCancel: viewModel.cancelSearch)
                VStack(spacing: 0) {
                    if viewModel.isSearchMode { recipeSearchSection }
                    else { savedRecipeListSection }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.backgroundPrimary)
            
            if viewModel.registrationState == .submitting {
                LoadingCurtain(title: "레시피를 플래너에 추가하고 있어요...")
                    .background(Color.white.opacity(0.9))
            }
        }
    }
    
    @ViewBuilder
    private var savedRecipeListSection: some View {
        switch viewModel.savedRecipesState {
        case .loading: LoadingCurtain(title: "저장한 레시피 목록을 불러오고 있어요...")
        case .loaded: PlannerRecipePickerRecipeList(
            headerTitle: "최근에 저장한 레시피",
            pagedRecipes: viewModel.pagedSavedRecipes,
            onRecipeTapped: viewModel.addToPlanner,
            onLoadMore: viewModel.loadMoreSavedRecipes)
        case .empty:
            Curtain(
            title: "저장한 레시피가 없어요.",
            description: "플래너에 추가할 레시피를 검색해보세요.",
            header: {
                Image("save-40")
                    .foregroundStyle(Color.gray15)
            }
        )
        case .error(let message): ErrorCurtain(message)
        }
    }
    
    @ViewBuilder
    private var recipeSearchSection: some View {
        if viewModel.keyword.isEmpty {
            Curtain(
            title: "플래너에 추가할 레시피 검색",
            description: "원하는 레시피의 키워드를 입력하세요.")
        } else {
            switch viewModel.searchState {
            case .searching: LoadingCurtain(title: "레시피를 찾고 있어요...")
            case .searched: PlannerRecipePickerRecipeList(
                headerTitle: "'\(viewModel.keyword)' 관련 레시피",
                pagedRecipes: viewModel.pagedSearchedRecipes,
                onRecipeTapped: viewModel.addToPlanner,
                onLoadMore: viewModel.loadMoreSearchedRecipes)
            case .empty:
                Curtain(
                    title: "원하는 레시피가 없어요.",
                    description: "'\(viewModel.keyword)' 관련 레시피를 하나도 찾지 못했어요.\n다른 키워드로 다시 검색해보세요.",
                    header: {
                        Image("info-200")
                            .resizable()
                            .foregroundStyle(Color.gray15)
                            .frame(width: 40, height: 40)
                    }
                )
            case .error(let message): ErrorCurtain(message)
            }
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }
    }
}

private struct PlannerRecipePickerRecipeList: View {
    let headerTitle: String
    let pagedRecipes: Paged<RecipeBasic>
    let onRecipeTapped: (Int64) -> Void
    let onLoadMore: () -> Void
    
    private var recipes: [RecipeBasic] { pagedRecipes.items }
    
    var body: some View {
        ScrollView {
            RecipeBasicList(
                recipes,
                hasNextPage: pagedRecipes.hasNextPage,
                onLoadMore: onLoadMore,
                onRecipeTapped: { recipeId in onRecipeTapped(recipeId) },
                headerContent: listHeader
            )
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func listHeader() -> some View {
        HStack {
            Text(headerTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .padding(.leading, 20)
            Spacer()
        }
        .padding(.top, 4)
        .padding(.vertical, 16)
    }
}
