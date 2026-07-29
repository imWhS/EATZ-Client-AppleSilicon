//
//  MyIngredientPantryView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/10/25.
//

import SwiftUI

struct MyIngredientPantryView: View {
    @StateObject private var viewModel = MyIngredientPantryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "보관함 속 재료들을 불러오고 있어요...")
            case .loaded:
                MyIngredientPantryList(
                    pagedIngredients: viewModel.pagedIngredients,
                    onLoadMore: viewModel.loadMoreIngredients,
                    onClear: viewModel.handleClearPantry,
                    onAction: viewModel.handleItemAction
                )
            case .empty: Curtain(
                title: "보관 중인 재료가 없어요.",
                description: "보관함에 아무 재료를 추가하지 않았어요."
            )
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .unauthorized: CommonUnauthorizedStateView()
            }
        }
        .transition(.opacity.animation(.easeInOut))
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationTitle("내 재료 보관함")
        .toolbar { addIngredientToolbarItem }
        .task {
            viewModel.setDismissAction(dismiss.callAsFunction)
            viewModel.prepareDataIfNeeded()
        }
        .alert(item: $viewModel.alert) { $0.alert }
        .sheet(item: $viewModel.sheet,
               onDismiss: viewModel.prepareDataIfNeeded,
               content: buildSheet)
    }
    
    @ViewBuilder
    private func buildSheet(for type: MyIngredientPantrySheet) -> some View {
        switch type {
        case .ingredientPicker: IngredientAdditionView()
        }
    }
    
    private var addIngredientToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("추가") { viewModel.sheet = .ingredientPicker }
                .disabled(viewModel.viewState == .unauthorized)
        }
    }
}

private struct MyIngredientPantryList: View {
    let pagedIngredients: Paged<Ingredient>
    let onLoadMore: () -> Void
    let onClear: () -> Void
    let onAction: (IngredientItemAction) -> Void
    
    private var ingredients: [Ingredient] { pagedIngredients.items }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                listHeader
                listSection
            }
        }
        .id(pagedIngredients.page == 0 ? UUID() : nil)
    }
    
    private var listHeader: some View {
        HStack {
            countText
            Spacer()
            HStack {
                Button("모두 제거", action: onClear).buttonStyle(SmallBorderlessButtonStyle())
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 14)
    }
    
    private var countLabel: String {
        let count = pagedIngredients.items.count
        return count < 1 ? "재료" : "\(count)개의 재료"
    }
    
    private var countText: some View {
        Text(countLabel)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.gray20)
            .padding(.leading, 20)
    }
    
    private var listSection: some View {
        LazyVStack(spacing: 8) {
            ForEach(ingredients) { ingredient in
                IngredientItem<EmptyView>(ingredient, onAction: onAction)
            }
            ListPageTailView(hasNextPage: pagedIngredients.hasNextPage, onAppearAction: onLoadMore)
        }
    }
}
