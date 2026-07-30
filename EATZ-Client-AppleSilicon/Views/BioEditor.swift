//
//  BioEditor.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/10/25.
//

import SwiftUI

struct BioEditor: View {
    @StateObject var viewModel = BioEditorViewModel()
    @FocusState private var isContentFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            viewStateContent
            .navigationTitle("소개 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
                doneToolbarItem
            }
            .onAppear {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
            .alert(item: $viewModel.alert) { $0.alert }
        }
    }
    
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "회원님의 소개를 불러오고 있어요...")
            case .loaded: mainContent
            case .error(let message):
                ErrorCurtain(
                    "회원님의 소개를 불러오지 못했어요. \(message)",
                    onRetry: viewModel.prepareDataIfNeeded)
            case .unauthorized: CommonUnauthorizedStateView()
            }
        }
        .background(Color.backgroundPrimary)
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("완료", action: viewModel.submit)
                .fontWeight(.semibold)
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                DynamicHeightTextView(
                    text: $viewModel.bio,
                    placeholder: "탭해서 소개 입력",
                    minHeight: 120,
                    maxHeight: 240,
                    isFocused: $isContentFocused
                )
                .padding(.horizontal, 20)
                .disabled(viewModel.isUpdatingBio)
                .opacity(viewModel.isUpdatingBio ? 0.5 : 1)
            }
        }
    }
}

#Preview {
    BioEditor()
}
