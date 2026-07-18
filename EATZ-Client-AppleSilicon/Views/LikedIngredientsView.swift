//
//  LikedIngredientsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/5/25.
//

import SwiftUI

struct LikedIngredientsView: View {
    @StateObject private var viewModel = LikedIngredientsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var presentExploreIngredientsView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading: LoadingCurtain(title: "좋아하는 재료 목록을 불러오고 있어요...")
                case .loaded: LikedIngredientList(
                    pagedIngredients: viewModel.pagedIngredients,
                    onAction: viewModel.handleItemAction,
                    onLoadMore: viewModel.loadMoreLikedIngredients)
                case .empty:
                    Curtain(
                        title: "좋아하는 재료가 없어요.",
                        description: "좋아할만한 재료를 찾아볼까요?",
                        actionTitle: "재료 둘러보기",
                        action: { presentExploreIngredientsView = true }
                    )
                case .unauthorized: CommonUnauthorizedStateView()
                case .error(let message): ErrorCurtain(message)
                }
            }
            .navigationTitle("좋아하는 재료")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
            }
        }
        .task {
            viewModel.subscribeToAuthState()
            viewModel.resetAndLoadAll()
        }
        .alert(item: $viewModel.alert) { $0.alert }
        .sheet(isPresented: $presentExploreIngredientsView, onDismiss: { viewModel.loadLikedIngredients(page: 0) }, content: { ExploreIngredientsView() })
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
}

private struct LikedIngredientList: View {
    let pagedIngredients: Paged<Ingredient>
    let onAction: (IngredientItemAction) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(pagedIngredients.items) { ingredient in
                    IngredientItem<EmptyView>(
                        ingredient,
                        onAction: onAction
                    )
//                    .onAppear {
//                        if ingredient.id == pagedIngredients.items.last?.id {
//                            onLoadMore()
//                        }
//                    }
                }
                ListPageTailView(hasNextPage: pagedIngredients.hasNextPage, onAppearAction: onLoadMore)
            }
        }
    }
}
