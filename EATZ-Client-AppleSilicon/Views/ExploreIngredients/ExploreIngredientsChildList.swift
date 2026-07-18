//
//  ExploreIngredientsChildList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import SwiftUI

struct ExploreIngredientsChildList: View {
    let parentId: Int64
    let parentName: String
    @EnvironmentObject private var viewModel: ExploreIngredientsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading = false
    
    init(parentId: Int64, parentName: String) {
        self.parentId = parentId
        self.parentName = parentName
    }
    
    var body: some View {
        mainContent
        .navigationTitle(parentName)
        .onAppear {
            viewModel.loadChildIngredients(for: parentId)
        }
        .alert(item: $viewModel.alert) { $0.alert }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if case .unauthorized = viewModel.viewState {
            CommonUnauthorizedStateView()
        } else {
            switch viewModel.childListState[parentId] {
            case .loading: LoadingCurtain(title: "\(parentName)의 하위 재료를 불러오고 있어요...")
            case .loaded: listView
            case .error(let message): ErrorCurtain(message)
            case .unauthorized: CommonUnauthorizedStateView()
            default: Curtain(title: "\(parentName)의 하위 재료가 하나도 없어요.")
            }
        }
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.childIngredients[parentId] ?? []) { childIngredient in
                    IngredientItem(
                        childIngredient,
                        isLinkable: true,
                        linkDestination: ExploreIngredientsChildList(parentId: parentId, parentName: parentName),
                        onAction: viewModel.handleItemAction)
                }
            }
        }
    }
}
