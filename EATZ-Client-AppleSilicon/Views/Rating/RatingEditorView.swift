//
//  RatingEditorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/25.
//

import SwiftUI
import Kingfisher

struct RatingEditorView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel: RatingEditorViewModel
    
    @FocusState private var isContentFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    
    @State private var initialScore: Int = 0
    @State private var initialContent: String = ""
    @State private var showDiscardAlert = false
    @State private var showScoreAlert = false // 추가
    
    var onComplete: () -> Void
    
    init(recipeId: Int64, onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: RatingEditorViewModel(recipeId: recipeId))
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 28) {
                    if let recipeEssential = viewModel.recipeEssential {
                        RatingEditorHeaderView(recipeEssential: recipeEssential)
                        HorizontalDividerView()
                    }

                    switch viewModel.existingRatingState {
                    case .idle:
                        EmptyView()
                    case .loading:
                        ProgressView("잠시만 기다려주세요...")
                    case .loaded:
                        if !authManager.isLoggedIn {
                            Text("로그아웃 상태입니다.")
                        } else {
                            RatingEditorFormView(
                                score: $viewModel.score,
                                content: $viewModel.content,
                                ratingEditorState: $viewModel.ratingEditorState,
                                isContentFocused: _isContentFocused
                            )
                        }
                    case .error(let message):
                        RatingEditorErrorMessageView(message: message)
                    }
                }
                .padding(.vertical, 28)
            }
            .background(Color.init("F9F9F9"))
            .navigationTitle(viewModel.existingRating != nil ? "평가 편집" : "새 평가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbar; trailingToolbar
            }
        }
        .onAppear {
            print("DBGTEST - hello RatingEditorView!")
        }
        .onChange(of: viewModel.existingRatingState, perform: handleRatingStateChange)
        .onChange(of: authManager.currentUser?.username, perform: handleUserChange)
        .task {
            viewModel.refreshAllData()
            authManager.fetchCurrentUser()
        }
        .alert(
            "잠깐! 변경된 내용이 있어요",
            isPresented: $showDiscardAlert,
            actions:  discardAlertActions,
            message: {
                Text("이 화면에서 나가면, 변경된 내용이 버려집니다.")
            }
        )
        .alert(
            "점수를 선택해주세요.",
            isPresented: $showScoreAlert) {
                Button("확인", role: .cancel) {}
        }
//        .sheetPresenter()
    }
    
    private func handleRatingStateChange(_ newState: ExistingRatingState) {
        if newState == .loaded {
            initialScore = viewModel.score
            initialContent = viewModel.content
        }
    }

    private func handleUserChange(_ username: String?) {
        if (username != nil && username != viewModel.currentUsername) {
            // 새로 로그인한 사용자가 기존과 다른 경우, 뷰를 dismiss 합니다.
            dismiss()
        } else if case .error = viewModel.existingRatingState {
            viewModel.refreshAllData()
        }
    }
    
    private var leadingToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                if viewModel.score != initialScore || viewModel.content != initialContent {
                    showDiscardAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
    
    private var trailingToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.ratingEditorState == .submitting {
                ProgressView()
            } else {
                Button("완료") {
                    guard viewModel.score > 0 else {
                        showScoreAlert = true
                        return
                    }
                    viewModel.submit {
                        dismiss()
                        onComplete()
                    }
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func discardAlertActions() -> some View {
      Group {
          Button("확인", role: .destructive) { dismiss() }
          Button("취소", role: .cancel) { }
      }
  }
        
}

private struct RatingEditorErrorMessageView: View {
    let message: String
    var body: some View {
        VStack {
            Text("문제가 발생했어요.")
                .font(.headline)
            Text(message)
                .font(.subheadline)
        }
    }
}

private struct RatingEditorHeaderView: View {
    var recipeEssential: RecipeEssential
    
    var body: some View {
        VStack(spacing: 20) {
            KFImage(URL(string: recipeEssential.imageUrl))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
                .frame(width: 104, height: 104)
                .clipped()
                .cornerRadius(16)
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(recipeEssential.authorUsername)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.init("8F8F8F"))
                    Text(recipeEssential.title)
                        .font(.system(size: 22, weight: .bold))
                }
                Text("레시피의 요리 경험을 공유해보세요.\n점수와 후기는 언제든지 수정할 수 있어요.")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init("787878"))
            }
        }
    }
}

struct RatingEditorFormView: View {
    @Binding var score: Int
    @Binding var content: String
    @Binding var ratingEditorState: RatingEditorState
    @FocusState var isContentFocused: Bool

    var body: some View {
        VStack(spacing: 40) {
            // 점수 입력 영역
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("점수")
                        .font(.system(size: 16, weight: .bold))
                    Text("별을 탭해서 레시피의 만족도를 표현해보세요.\n별의 개수로 1점부터 5점까지의 점수가 결정돼요.")
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(Color("787878"))
                }
                RatingPicker(rating: $score)
                    .disabled(ratingEditorState == .submitting)
                    .opacity(ratingEditorState == .submitting ? 0.25 : 1)
            }

            // 후기 입력 영역
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("후기")
                        .font(.system(size: 16, weight: .bold))
                    Text("레시피에 대한 자세한 생각을 작성해보세요.\n원하지 않으신다면 비워두셔도 돼요.")
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(Color("787878"))
                }
                BasicTextEditor(text: $content, isFocused: $isContentFocused)
                    .padding(.horizontal, 20)
                    .disabled(ratingEditorState == .submitting)
                    .opacity(ratingEditorState == .submitting ? 0.25 : 1)
            }
        }
    }
}
