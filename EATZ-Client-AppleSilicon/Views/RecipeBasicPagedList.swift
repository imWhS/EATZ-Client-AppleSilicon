//
//  RecipeBasicPagedList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/1/25.
//

import SwiftUI

struct RecipeBasicPagedList<EmptyViewContent: View, MenuContent: View>: View {
    @ObservedObject var viewModel: RecipeBasicListViewModel
    @EnvironmentObject private var router: Router
    @Environment(\.dismiss) private var dismiss
    
    @ViewBuilder let emptyView: () -> EmptyViewContent
    @ViewBuilder let menuContent: (RecipeBasic) -> MenuContent
    
    private var recipes: [RecipeBasic] { viewModel.pagedRecipes.items }
    private let navigationTitle: String
    private let auth: AuthProvider
    
    init(
        _ viewModel: RecipeBasicListViewModel,
        auth: AuthProvider = AuthManager.shared,
        navigationTitle: String,
        @ViewBuilder emptyView: @escaping () -> EmptyViewContent,
        @ViewBuilder menuContent: @escaping (RecipeBasic) -> MenuContent
    ) {
        self.viewModel = viewModel
        self.auth = auth
        self.navigationTitle = navigationTitle
        self.emptyView = emptyView
        self.menuContent = menuContent
    }
    
    var body: some View {
        viewStateContent
            .task {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
            .navigationTitle(navigationTitle)
            .alert(item: $viewModel.alert) { $0.alert }
    }
    
    @ViewBuilder
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "레시피 목록을 불러오고 있어요...")
            case .loaded: mainContent
            case .empty: emptyView()
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .unauthorized: CommonUnauthorizedStateView()
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            RecipeBasicList(
                recipes,
                hasNextPage: viewModel.pagedRecipes.hasNextPage,
                onLoadMore: viewModel.loadNextPage,
                onRecipeTapped: { recipeId in router.push(.recipe(id: recipeId)) },
                headerContent: listHeader,
                menuContent: menuContent
            )
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: recipes)
    }
    
    private func listHeader() -> some View {
        HStack {
            Text(viewModel.totalElementsLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .padding(.leading, 20)
            Spacer()
        }
        .padding(.top, 4)
        .padding(.vertical, 16)
    }
}
