//
//  CommentView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/25.
//

// TODO: 에디터 필드 입력 내용 있을 때 pop 하려는 경우 alert 띄우기
import SwiftUI

struct CommentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject var viewModel: CommentViewModel
    
    init(recipeId: Int64) {
        _viewModel = StateObject(wrappedValue: CommentViewModel(for: recipeId))
    }
    
    var body: some View {
        Group {
            if case .loaded = viewModel.viewState,
               !viewModel.pagedCommentsWithPermissions.isEmpty
            {
                ScrollView {
                    commentView
                }
                .refreshable { await viewModel.refresh() }
            } else {
                commentView
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.presentEditor {
                CommentEditor(authManager: authManager, viewModel: viewModel)
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
        .toolbarBackground(.hidden, for: .tabBar)
        .navigationTitle(viewModel.navigationTitleLabel)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: authManager.currentUser) {
            viewModel.authManager = authManager
            viewModel.prepareDataIfNeeded()
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .getBlockContext(
            targetUser: $viewModel.blockTargetUser,
            onSuccess: { Task { await viewModel.refresh() } })
        .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private var commentView: some View {
        VStack(spacing: 0) {
            recipeEssentialWrapperView
            
            switch viewModel.viewState {
            case .initialLoading: LoadingCurtain(title: "레시피에 달린 댓글 목록을 불러오고 있어요...")
            case .loaded: contentView
            case .error(let message): ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.pagedCommentsWithPermissions.isEmpty {
            CommonEmptyStateView(
                title: "보여드릴 댓글이 없어요.",
                "아직 아무도 이 레시피에 댓글을 남기지 않았어요.",
                "comment-40"
            )
        } else {
            CommentList(
                viewModel.pagedCommentsWithPermissions,
                viewModel.loadMoreComments,
                viewModel.handleAction)
        }
    }
    
    @ViewBuilder
    private var recipeEssentialWrapperView: some View {
        if let recipeEssential = viewModel.recipeEssential {
            RecipeEssentialView(recipeEssential, style: .white)
        } else {
            EmptyView()
        }
    }
}

enum CommentAlert {
    case commentDisabled
    case confirmDelete(type: CommentDeleteActionType, confirmAction: () -> Void)
    case deletionSuccess(isMine: Bool)
    case confirmDiscardChanges(confirmAction: () -> Void)
    case confirmChangeUpdatingComment(confirmAction: () -> Void)
    case error(title: String? = nil, message: String)
    
    var title: String {
        switch self {
        case .commentDisabled: return "댓글 기능 해제됨"
        case .confirmDelete(let type, _): return type.isMine ? "내 댓글 삭제" : "댓글 삭제"
        case .deletionSuccess(let isMine): return isMine ? "내 댓글 삭제 완료" : "댓글 삭제 완료"
        case .confirmDiscardChanges(_): return "댓글 편집 종료"
        case .confirmChangeUpdatingComment(_): return "편집할 댓글 변경"
        case .error(let title, _): return title ?? "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .commentDisabled:
            Button("확인", role: .cancel) {}
        case .confirmDelete(_, let confirmAction):
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: confirmAction)
        case .deletionSuccess(_):
            Button("확인", role: .cancel) {}
        case .confirmDiscardChanges(let confirmAction):
            Group {
                Button("취소", role: .cancel) {}
                Button("버리기", role: .destructive, action: confirmAction)
            }
        case .confirmChangeUpdatingComment(let confirmAction):
            Group {
                Button("취소", role: .cancel) {}
                Button("버리기", role: .destructive, action: confirmAction)
            }
        case .error(_, _):
            Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .commentDisabled: Text("댓글 기능이 해제된 레시피예요. 레시피의 작성자가 댓글 기능을 다시 사용하도록 설정해야 댓글을 달거나 수정할 수 있어요.")
        case .confirmDelete(let type, _):
            let username = type.comment.author.username
            let authorLabel = type.isMine ? "회원" : "\(username)"
            Text("\(authorLabel)님의 댓글을 삭제할까요? 삭제된 댓글은 복구할 수 없어요.")
        case .deletionSuccess(let isMine): Text("\(isMine ? "회원님의 " : "")댓글을 삭제했어요.")
        case .confirmDiscardChanges(_): Text("작성 또는, 변경하고 있던 내용을 버리시겠어요?")
        case .confirmChangeUpdatingComment(_): Text("작성 또는, 변경하고 있던 내용을 버리고 다른 댓글을 편집할까요?")
        case .error(_, let message): Text(message);
        }
    }
}
