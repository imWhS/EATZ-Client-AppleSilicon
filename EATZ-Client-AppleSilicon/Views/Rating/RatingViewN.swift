//
//  RatingViewN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/10/26.
//

// C.C.

import SwiftUI

struct RatingViewN: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = RatingViewModelN()
    
    private let recipeId: Int64
    
    private var currentUser: CurrentUser? {
        authManager.currentUser
    }
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    private var ratingView: some View {
        Group {
            switch viewModel.state {
            case .initialLoading: LoadingCurtain(title: "평가를 불러오고 있어요...")
            case .content(let recipeEssential, let pagedRatings):
                RatingContentView(authManager, viewModel, recipeEssential, pagedRatings, recipeId)
            case .error(let message):
                ErrorCurtain(message, onRetry: { viewModel.load(for: recipeId, currentUser) })
            }
        }
    }
    
    var body: some View {
        ratingView
            .navigationTitle(viewModel.navigationTitleLabel)
            .navigationBarTitleDisplayMode(.inline)
            .task(id: recipeId) {
                viewModel.loadInitial(for: recipeId, currentUser)
            }
            .onChange(of: currentUser, handleCurrentUserChanged)
            .refreshable { await viewModel.refresh(for: recipeId, currentUser) }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: Binding.init(isPresenting: $viewModel.alert),
                presenting: viewModel.alert,
                actions: { $0.actions },
                message: { $0.message })
            .fullScreenCover(
                item: $viewModel.fullScreenCover,
                onDismiss: { Task { await viewModel.refresh(for: recipeId, currentUser) } },
                content: buildFullScreenCover)
            .getBlockContext(
                targetUser: $viewModel.blockTargetUser,
                onSuccess: { Task { await viewModel.refresh(for: recipeId, currentUser) } })
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private func buildFullScreenCover(for type: RatingFullScreenCover) -> some View {
        switch type {
        case .ratingEditor(let recipeId, let mode): RatingEditor(recipeId: recipeId, mode: mode)
        }
    }
    
    private func handleCurrentUserChanged(previous: CurrentUser?, new: CurrentUser?) {
        if previous?.id != new?.id {
            Task { await viewModel.refresh(for: recipeId, new) }
        }
    }
}

enum RatingAlert {
    case confirmDelete(type: RatingDeleteActionType, confirmAction: () -> Void)
    case deletionSuccess(isMine: Bool)
    case error(title: String?, message: String)
    
    var title: String {
        switch self {
        case .confirmDelete(let type, _): return type.isMine ? "내 평가 삭제" : "평가 삭제"
        case .deletionSuccess(let isMine): return isMine ? "내 평가 삭제 완료" : "평가 삭제 완료"
        case .error(let title, _): return title ?? "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmDelete(_, let confirmAction):
            Group {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive, action: confirmAction)
            }
        case .deletionSuccess: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmDelete(let type, _):
            let username = type.rating.author.username
            let authorLabel = type.isMine ? "회원" : "\(username)"
            Text("\(authorLabel)님의 평가를 삭제할까요? 삭제된 평가는 복구할 수 없어요.")
        case .deletionSuccess(let isMine): Text("\(isMine ? "회원님의 " : "")평가를 삭제했어요.")
        case .error(_, let message): Text(message)
        }
    }
}

enum RatingFullScreenCover: Identifiable {
    case ratingEditor(recipeId: Int64, mode: RatingEditorMode)
    
    var id: String {
        switch self {
        case .ratingEditor(let recipeId, let mode):
            return "ratingEditor-\(recipeId)-\(mode == .create ? "create" : "update")"
        }
    }
}
