//
//  KitchenwarePicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

struct KitchenwarePicker: View {
    @StateObject private var viewModel: KitchenwarePickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(initialSelection: Binding<[KitchenwareEssential]>) {
        _viewModel = StateObject(wrappedValue: KitchenwarePickerViewModel(initialSelection: initialSelection))
    }
    
    var body: some View {
        viewStateContent
            .task {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
            .alert(item: $viewModel.alert) { $0.alert }
    }
    
    private var viewStateContent: some View {
        VStack {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "도구 목록을 불러오고 있어요...")
            case .loaded: mainContent
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .empty: Curtain(title: "보여드릴 도구가 없어요.")
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            NavigationStack {
                SelectableKitchenwareList<KitchenwarePickerViewModel>(
                    kitchenwares: viewModel.kitchenwares,
                    searchedKitchenwares: viewModel.searchedKitchenwares,
                    searchKeyword: $viewModel.searchKeyword,
                    searchState: viewModel.searchState,
                    isItemSelected: { item in viewModel.isSelected(item.id) },
                    isItemDisabled: { _ in false },
                    onToggleSelection: viewModel.toggleSelection)
                .navigationTitle("도구")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    dismissToolbarItem
                    doneToolbarItem
                }
            }
            .environmentObject(viewModel)
            SelectedKitchenwareBar(selection: viewModel.selectedKitchenwares, onToggleSelection: viewModel.toggleSelection, placeholder: "목록에서 레시피에 추가할 도구를 선택하거나,\n원하는 도구 이름으로 검색해서 레시피에 추가할 도구를 선택하세요.")
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
            Button("완료", action: { viewModel.complete() }).fontWeight(.semibold)
        }
    }
}
