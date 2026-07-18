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
    
    init(authManager: AuthManager, viewModel: CommentViewModel) {
        self.authManager = authManager
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider(padding: 0)
            if let recipeEssential = viewModel.recipeEssential,
               recipeEssential.commentEnabled {
                if authManager.currentUser != nil {
                    switch viewModel.registrationState {
                    case .idle: commentEditorView
                    case .registering: ProgressView()
                    case .error(let message): Text(message)
                    }
                } else {
                    commentLogInView
                }
            } else {
                commentUnavailableView
            }
        }
        .background(Color.white)
    }
    
    var commentEditorView: some View {
        VStack(spacing: 12) {
            if viewModel.isEditing { header }
            editor
        }
        .padding(.horizontal, 20)
        .padding(.top, viewModel.isEditing ? 12 : 20)
        .padding(.bottom, 20)
        .background(Color.white)
        .onChange(of: viewModel.isEditorFocused) { oldValue, newValue in
            self.isCommentFieldFocusedInternal = newValue
        }
        .onChange(of: isCommentFieldFocusedInternal) { oldValue, newValue in
            viewModel.isEditorFocused = newValue
        }
        .animation(.easeInOut, value: viewModel.editingContent)
        .animation(.easeInOut, value: viewModel.isEditing)
    }
    
    private var header: some View {
        HStack {
            Text("댓글 수정 중")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.init(hex: "8F8F8F"))
            Spacer()
            Button("취소", action: viewModel.cancelEditingComment)
                .fontWeight(.semibold)
                .buttonStyle(SmallBorderlessButtonStyle())
        }
    }
    
    private var editor: some View {
        HStack(alignment: .bottom, spacing: 12) {
            HStack(alignment: .bottom) {
                ProfileImageView(imageUrl: authManager.currentUser?.imageUrl, size: 32)
                DynamicHeightTextView(
                    text: $viewModel.editingContent,
                    placeholder: "탭해서 댓글 내용 입력",
                    minHeight: 32,
                    padding: .init(),
                    cornerRadius: 0,
                    stroke: .clear,
                    strokeHighlighted: .clear,
                    isFocused: $isCommentFieldFocusedInternal
                )
            }
            Button("게시", action: viewModel.handleSubmitEdit)
                .buttonStyle(SmallRoundedButtonStyle(type: .primary))
        }
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
    
    private var commentUnavailableView: some View {
        VStack(spacing: 12) {
//            if authManager.currentUser?.id == viewModel.recipeEssential?.authorId {
//                Button(action: {  }) { Text("댓글 기능 사용") }
//                    .buttonStyle(SmallRoundedButtonStyle(type: .primary))
//            }
//            
            Text("댓글 기능이 해제된 레시피예요. 댓글 기능을 사용하도록 설정했을 때 달린 댓글만 볼 수 있어요.")
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(Color.init(hex: "BCBCBC"))
        }
        .padding(20)
    }
    
    private var signWithEmailButton: some View {
        Button(action: authManager.requireAuthView) { Text("이메일로 시작") }
            .buttonStyle(SmallRoundedButtonStyle(type: .primary))
            .accentColor(Color.init(hex: "55C374"))
    }
}
