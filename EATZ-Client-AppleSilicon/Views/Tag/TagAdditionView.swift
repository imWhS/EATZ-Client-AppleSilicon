//
//  TagAdditionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/24/25.
//

import SwiftUI

struct TagAdditionView: View {
    @StateObject private var viewModel = TagAdditionViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var onSelect: (TagPickerSelectionType) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerTextFieldSection
                mainSection
            }
            .background(Color.white)
            .navigationTitle("태그")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { dismissToolbarItem }
            .onAppear { isTextFieldFocused = true }
            .alert(item: $viewModel.alert) { $0.alert }
        }
        .task(id: viewModel.currentUser) {
            viewModel.setActions(onDismiss: dismiss.callAsFunction, onSelect: onSelect)
            viewModel.prepareDataIfNeeded()
        }
    }
    
    private var headerTextFieldSection: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TextField("탭해서 태그 입력", text: $viewModel.searchKeyword)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                Button("추가", action: {
                    viewModel.confirmSelection(.new(viewModel.searchKeyword))
                })
                .buttonStyle(SmallRoundedButtonStyle(type: .primary))
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private var mainSection: some View {
        Group {
            switch viewModel.viewState {
            case .explorable: exploringContainer
            case .searchable: searchingContainer
            }
        }
        .background(Color.backgroundPrimary)
    }
    
    private var exploringContainer: some View {
        ScrollView {
            ExploreThemes(
                featuredThemesState: viewModel.featuredThemesState,
                pagedAllThemes: viewModel.pagedThemes,
                onLoadMoreAllThemes: viewModel.loadMoreAllThemes,
                onSelect: { tagTheme in viewModel.confirmSelection(.existing(tagTheme.name)) },
                onRetry: viewModel.prepareDataIfNeeded)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    @ViewBuilder
    private var searchingContainer: some View {
        switch viewModel.searchState {
        case .searching:
            Curtain(title: "태그를 찾고 있어요...")
        case .searched(let pagedSearchedTags):
            TagList(
                pagedTags: pagedSearchedTags,
                onSelect: { viewModel.confirmSelection(.existing($0.name)) },
                onLoadMore: viewModel.loadMoreSearchedTags
            )
        case .searchedEmpty(let keyword):
            Curtain(
                title: "원하는 태그가 없어요.",
                description: "'\(keyword)'에 해당하는 재료를 하나도 찾지 못했어요.\n다른 검색어를 사용해보세요.")
        case .error(let message): ErrorCurtain(message)
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
    }
}

struct TagPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TagAdditionView { selection in
            switch selection {
            case .existing(let tagName):
                print("기존 태그 선택됨: \(tagName)")
            case .new(let tagName):
                print("새 태그 추가: \(tagName)")
            }
        }
    }
}
