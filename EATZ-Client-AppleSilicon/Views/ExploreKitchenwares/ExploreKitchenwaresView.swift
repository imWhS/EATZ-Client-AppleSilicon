//
//  ExploreKitchenwaresView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/6/25.
//

import SwiftUI

struct ExploreKitchenwaresView: View {
    @StateObject private var viewModel = ExploreKitchenwaresViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        mainContent
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
                case .loading: LoadingCurtain(title: "도구 목록을 불러오고 있어요...")
                case .loaded:
                    ExploreKitchenwaresList(
                        pagedKitchenwares: viewModel.pagedKitchenwares,
                        pagedSearchedKitchenwares: viewModel.pagedSearchedKitchenwares,
                        searchKeyword: $viewModel.searchKeyword,
                        searchState: viewModel.searchState,
                        onItemAction: viewModel.handleItemAction,
                        showNavigationBarTitle: $viewModel.showNavigationBarTitle,
                        onLoadMoreKitchenwares: viewModel.loadMoreKitchenwares,
                        onLoadMoreSearchedKitchenwares: viewModel.loadMoreSearchedIngredients
                    )
                    .environmentObject(viewModel)
                case .unauthorized: CommonUnauthorizedStateView()
                case .error(let message): ErrorCurtain(message)
                case .empty:
                    Curtain(
                        title: "보여드릴 도구가 없어요.",
                        header: {
                            Image("info-200")
                                .resizable()
                                .foregroundStyle(Color.gray15)
                                .frame(width: 40, height: 40)
                        }
                    )
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
            Text("도구 둘러보기")
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
