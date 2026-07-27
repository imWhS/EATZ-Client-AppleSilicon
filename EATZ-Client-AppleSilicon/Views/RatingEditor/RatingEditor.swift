//
//  RatingEditor.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/25.
//

import SwiftUI
import Kingfisher

struct RatingEditor: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = RatingEditorViewModelN()
    
    @FocusState private var isContentFocused: Bool
    
    private let recipeId: Int64
    private let mode: RatingEditorMode
    private let onSubmitCompleted: () -> Void
    private let textViewScrollID = "textViewBottom"
    
    init(recipeId: Int64, mode: RatingEditorMode, onSubmitCompleted: @escaping () -> Void = {}) {
        self.recipeId = recipeId
        self.mode = mode
        self.onSubmitCompleted = onSubmitCompleted
    }
    
    private var ratingEditor: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initialLoading: LoadingCurtain(title: "평가를 편집하기 위해 준비하고 있어요...")
                case .content: contentView
                case .error(let message): ErrorCurtain(message, onRetry: { viewModel.load(authManager) })
                case .unauthorized: CommonUnauthorizedStateView()
                }
            }
            .navigationTitle(viewModel.navigationTitleLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem; doneToolbarItem
            }
        }
    }
    
    var body: some View {
        ratingEditor
            .task {
                if viewModel.currentUser == nil {
                    viewModel.currentUser = authManager.currentUser
                }
                
                viewModel.loadInitial(recipeId, mode, authManager)
            }
            .onChange(of: authManager.currentUser) { _, newUser in
                viewModel.validateAndPrepareUser(authManager)
            }
            .onChange(of: viewModel.routingAction) { _, routingAction in
                switch routingAction {
                case .dismiss: dismiss.callAsFunction()
                case .submitCompleted:
                    onSubmitCompleted()
                    dismiss.callAsFunction()
                case .none: break
                }
            }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: isAlertPresented,
                presenting: viewModel.alert,
                actions: { $0.actions },
                message: { $0.message })
    }
    
    private var isAlertPresented: Binding<Bool> {
        Binding(
            get: { viewModel.alert != nil },
            set: { isPresented in
                DispatchQueue.main.async {
                    if !isPresented { self.viewModel.alert = nil }
                }
            }
        )
    }
    
    private var contentView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 28) {
                    if let recipeEssential = viewModel.recipeEssential {
                        RatingEditorHeader(recipeEssential: recipeEssential)
                        HorizontalDivider()
                    }
                    RatingEditorDraftView(
                        score: $viewModel.currentDraft.score,
                        content: $viewModel.currentDraft.content,
                        submissionState: $viewModel.submissionState,
                        isContentFocused: _isContentFocused,
                        textViewScrollID: self.textViewScrollID)
                }
                .padding(.vertical, 28)
            }
            .onChange(of: viewModel.currentDraft.content) { _, _ in
                withAnimation {
                    proxy.scrollTo(textViewScrollID, anchor: .bottom)
                }
            }
            .background(Color.init(hex: "F9F9F9"))
        }
    }
    
    private var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.handleDismissAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.submissionState == .submitting {
                ProgressView()
            } else {
                Button("완료", action: viewModel.handleSubmit)
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isSubmittable)
            }
        }
    }
}

enum RatingEditorAlert: Identifiable {
    case hasUnsavedChanges(confirmAction: () -> Void)
    case scoreNotSelected(confirmAction: () -> Void)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(title: String? = nil, message: String)
    
    var id: String {
        switch self {
        case .hasUnsavedChanges: return "hasUnsavedChanges"
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .scoreNotSelected: return "scoreNotSelected"
        case .error(let title, let message): return "\(title ?? "")-\(message)"
        }
    }
    
    var title: String {
        switch self {
        case .hasUnsavedChanges: "변경 사항 존재"
        case .scoreNotSelected: "필수 항목 누락"
        case .userChanged: "사용자 변경"
        case .sessionExpired: "세션 만료"
        case .error(let title, _): title ?? "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .hasUnsavedChanges(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive, action: confirmAction)
        case .scoreNotSelected(let confirmAction): Button("확인", action: confirmAction)
        case .userChanged(let dismissAction): Button("확인", action: dismissAction)
        case .sessionExpired(let dismissAction): Button("확인", action: dismissAction)
        case .error(_, _): Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .hasUnsavedChanges: Text("이 화면에서 나가면, 변경된 내용이 버려집니다.")
        case .scoreNotSelected: Text("평가의 점수를 선택해주세요. 평가의 점수는 필수 항목이에요.")
        case .userChanged: Text("기존과 다른 사용자로 로그인됐어요. 평가 편집을 종료할게요.")
        case .sessionExpired: Text("로그아웃 상태로 전환됐어요. 평가 편집을 종료할게요.")
        case .error(_, let message): Text(message)
        }
    }
}
