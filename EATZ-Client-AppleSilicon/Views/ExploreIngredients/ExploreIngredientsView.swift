//
//  ExploreIngredientsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/6/25.
//

import SwiftUI

struct ExploreIngredientsView: View {
    @StateObject private var viewModel = ExploreIngredientsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        mainContent
            .environmentObject(viewModel)
            .alert(item: $viewModel.alert) { $0.alert }
            .onAppear {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
    }
    
    private var mainContent: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading: LoadingCurtain(title: "재료 목록을 불러오고 있어요...")
                case .loaded: ExploreIngredientsList()
                case .unauthorized: CommonUnauthorizedStateView()
                case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
                case .empty: Curtain(title: "보여드릴 재료가 없어요.")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                titleToolbarItem
                dismissToolbarItem
            }
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("재료 둘러보기")
                .font(.headline)
                .opacity(viewModel.showNavigationBarTitle ? 1 : 0)
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark").font(.system(size: 17, weight: .semibold))
            }
        }
    }
}
