//
//  MyKitchenwarePantryView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/10/25.
//

import SwiftUI
import Kingfisher

struct MyKitchenwarePantryView: View {
    @StateObject private var viewModel = MyKitchenwarePantryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "보관함 속 도구들을 불러오고 있어요...")
            case .loaded:
                MyKitchenwarePantryList(
                    pagedKitchenwares: viewModel.pagedKitchenwares,
                    onLoadMore: viewModel.loadMoreKitchenwares,
                    onClear: viewModel.handleClearPantry,
                    onAction: viewModel.handleItemAction
                )
            case .empty: Curtain(
                title: "보관 중인 도구가 없어요.",
                description: "보관함에 아무 도구를 추가하지 않았어요."
            )
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .unauthorized: CommonUnauthorizedStateView()
            }
        }
        .transition(.opacity.animation(.easeInOut))
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationTitle("내 도구 보관함")
        .toolbar { addKitchenwareToolbarItem }
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
    private func buildSheet(for type: MyKitchenwarePantrySheet) -> some View {
        switch type {
        case .kitchenwarePicker: KitchenwareAdditionView()
        }
    }
    
    private var addKitchenwareToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("추가") { viewModel.sheet = .kitchenwarePicker }
                .disabled(viewModel.viewState == .unauthorized)
        }
    }
}

private struct MyKitchenwarePantryList: View {
    let pagedKitchenwares: Paged<Kitchenware>
    let onLoadMore: () -> Void
    let onClear: () -> Void
    let onAction: (KitchenwareItemAction) -> Void
    
    private var kitchenwares: [Kitchenware] { pagedKitchenwares.items }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                listHeader
                listSection
            }
        }
        .id(pagedKitchenwares.page == 0 ? UUID() : nil)
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
        let count = pagedKitchenwares.items.count
        return count < 1 ? "도구" : "\(count)개의 도구"
    }
    
    private var countText: some View {
        Text(countLabel)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.gray35)
            .padding(.leading, 20)
    }
    
    private var listSection: some View {
        LazyVStack(spacing: 8) {
            ForEach(kitchenwares) { kitchenware in
                KitchenwareItem(kitchenware, onAction: onAction)
            }
            ListPageTailView(hasNextPage: pagedKitchenwares.hasNextPage, onAppearAction: onLoadMore)
        }
    }
}
