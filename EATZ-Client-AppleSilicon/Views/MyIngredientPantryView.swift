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
            case .loading: LoadingCurtain(title: "보관함 속의 모든 재료를 불러오고 있어요...")
            case .loaded:
                MyIngredientPantryList(
                    pagedIngredients: viewModel.pagedIngredients,
                    loadMore: viewModel.loadMoreIngredients,
                    onClear: viewModel.handleClearPantry,
                    action: viewModel.handleItemAction
                )
            case .empty:
                CommonEmptyStateView(
                    title: "보관하고 있는 재료가 없어요.",
                    "보관함에 아무 재료를 추가하지 않았어요."
                )
            case .error(let message): ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded)
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
    let loadMore: () -> Void
    let onClear: () -> Void
    let action: (IngredientItemAction) -> Void
    
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
            .foregroundStyle(Color.gray35)
            .padding(.leading, 20)
            .contentTransition(.numericText())
            .animation(.snappy, value: pagedIngredients.items.count)
    }
    
    private var listSection: some View {
        LazyVStack(spacing: 8) {
            ForEach(ingredients) { ingredient in
                IngredientItem<EmptyView>(ingredient, action: action)
            }
            ListPageTailView(hasNextPage: pagedIngredients.hasNextPage, onAppear: loadMore)
        }
    }
}
