//
//  CommentEditor.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/20/25.
//

import SwiftUI

struct CommentEditor: View {
    @ObservedObject private var authManager: AuthManager
    @ObservedObject private var viewModel: CommentViewModel
    @FocusState private var isCommentFieldFocusedInternal: Bool
    
    init(_ authManager: AuthManager, _ viewModel: CommentViewModel) {
        self.authManager = authManager
        self.viewModel = viewModel
    }
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .onChange(of: viewModel.isEditorFocused) { _, isEditorFocused in
                self.isCommentFieldFocusedInternal = isEditorFocused
            }
            .onChange(of: isCommentFieldFocusedInternal) { _, isCommentFieldFocusedInternal in
                self.viewModel.isEditorFocused = isCommentFieldFocusedInternal
            }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            if let recipeEssential = viewModel.recipeEssential,
               recipeEssential.commentEnabled {
                Group {
                    if authManager.currentUser != nil {
                        switch viewModel.registrationState {
                        case .idle: fieldView
                        case .registering: ProgressView()
                        case .error(let message): Text(message)
                        }
                    } else {
                        commentLogInView
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: viewModel.isEditing ? 24 : 32))
        .shadow(
            color: .black.opacity(0.1),
            radius: 8,
            y: 4
        )
        .animation(.snappy(duration: 0.25), value: viewModel.isEditing)
        .animation(.snappy(duration: 0.25), value: viewModel.registrationState)
    }
    
    private var fieldView: some View {
        VStack(spacing: 0) {
            if viewModel.isEditing { editingStateHeader }
            editor
        }
    }
    
    private var editingStateHeader: some View {
        HStack {
            Text("댓글 수정 중")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.gray20)
            Spacer()
            Button("취소", action: viewModel.cancelEditingComment)
                .fontWeight(.semibold)
                .buttonStyle(CapsuleButtonStyle(status: viewModel.hasCommentUnsavedChanges ? .danger : .secondary))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var editor: some View {
        HStack(alignment: .bottom, spacing: 12) {
            HStack(alignment: .bottom) {
                ProfileImageView(authManager.currentUser?.imageUrl, size: 32)
                DynamicHeightTextView(
                    text: $viewModel.editingContent,
                    placeholder: "탭해서 댓글 내용 입력",
                    minHeight: 28,
                    padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                    cornerRadius: 0,
                    stroke: .clear,
                    strokeHighlighted: .clear,
                    isFocused: $isCommentFieldFocusedInternal
                )
            }
            Button("게시", action: viewModel.handleSubmitEdit)
                .buttonStyle(CapsuleButtonStyle(status: .primary))
        }
        .padding(.horizontal, 16)
    }
    
    private var commentLogInView: some View {
        VStack(spacing: 12) {
            Image("handshake")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .foregroundStyle(Color.init(hex: "D1E7D7"))
            VStack(spacing: 12) {
                signWithEmailButton
                Text("로그인 또는 가입하면 댓글을 등록할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Color.init(hex: "93A197"))
            }
        }
        .padding(.vertical, 20)
    }
    
    private var signWithEmailButton: some View {
        Button(action: authManager.requireAuthView) { Text("이메일로 시작") }
            .buttonStyle(RoundedButtonStyle(.authPrimary, .medium))
    }
}
