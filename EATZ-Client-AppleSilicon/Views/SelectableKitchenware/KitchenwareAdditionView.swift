//
//  KitchenwareAdditionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

struct KitchenwareAdditionView: View {
    @StateObject private var viewModel = KitchenwareAdditionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        viewStateContent
            .alert(item: $viewModel.alert) { $0.alert }
            .onAppear {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
    }
    
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "도구 목록을 불러오고 있어요...")
            case .loaded: mainContent
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message)
            case .empty: Curtain(title: "보여드릴도구가 없어요.")
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            NavigationStack {
                SelectableKitchenwareList<KitchenwareAdditionViewModel>(
                    kitchenwares: viewModel.kitchenwares,
                    searchedKitchenwares: viewModel.searchedKitchenwares,
                    searchKeyword: $viewModel.searchKeyword,
                    searchState: viewModel.searchState,
                    isItemSelected: { item in viewModel.isSelected(item.id) },
                    isItemDisabled: { item in item.ownedByUser },
                    onToggleSelection: viewModel.toggleSelection)
                .navigationTitle("도구")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    dismissToolbarItem
                    doneToolbarItem
                }
            }
            .environmentObject(viewModel)
            SelectedKitchenwareBar(selection: viewModel.selectedKitchenwares, onToggleSelection: viewModel.toggleSelection, placeholder: "목록에서 보관함에 추가할 도구를 선택하거나,\n원하는 도구 이름으로 검색해서 보관함에 추가할 도구를 선택하세요.")
        }
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
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("완료", action: { viewModel.complete() })
                .fontWeight(.semibold)
                .disabled(viewModel.selectedKitchenwares.isEmpty)
        }
    }
}
