//
//  RatingView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI
import Kingfisher

enum RatingDeleteType: Equatable, Identifiable {
    case mine
    case other(username: String)
    
    var id: String {
        switch self {
        case .mine:
            return "mine"
        case .other(let username):
            return "other_\(username)"
        }
    }
}

enum RatingViewAlert: Identifiable, Equatable {
    case confirmDelete(type: RatingDeleteType, rating: RatingItem)
    case deletionSuccess(type: RatingDeleteType)

    var id: String {
        switch self {
        case .confirmDelete(let type, let rating):
            return "confirmDelete_\(type.id)_\(rating.id)"
        case .deletionSuccess:
            return "deletionSuccess"
        }
    }
}

struct RatingView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel: RatingViewModel
    
    @State private var deleteType: RatingDeleteType? = nil
    @State private var ratingToDelete: RatingItem? = nil
    @State private var showDeleteRatingAlert = false
    @State private var showSuccessDeletionMyRatingAlert = false
    
    @State private var alert: RatingViewAlert? = nil
    @State private var isPresentingEditor = false
    
    init(recipeId: Int64) {
        _viewModel = StateObject(wrappedValue: RatingViewModel(recipeId: recipeId))
    }
    
    var body: some View {
        Group {
            if viewModel.shouldShowEmptyView {
                VStack(spacing: 0) {
                    RatingRecipeEssentialView(state: viewModel.recipeEssentialState)
                    RatingEmptyView(isLoggedIn: authManager.isLoggedIn, onRegister: registerRatingWithoutAuth)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        RatingRecipeEssentialView(state: viewModel.recipeEssentialState)
                        RatingSummaryView(state: viewModel.ratingSummaryState)
                        RatingMySectionView(
                            currentUser: authManager.currentUser,
                            state: viewModel.myRatingState,
                            onEdit: editMyRating,
                            onDelete: { rating in triggerDelete(type: .mine, rating: rating) },
                            onLogIn: {
                                authManager.performAfterLogIn {
                                    viewModel.reloadAllRatings()
                                }
                            }
                        )
                        RatingListSectionView(
                            ratings: viewModel.ratings,
                            canManage: canManage,
                            onHide: { id in hideRating(id) },
                            onDelete: { rating in triggerDelete(type: .other(username: rating.user.username), rating: rating) }
                        )
                    }
                }
            }
        }
        .alert(item: $alert) { alert in
            switch alert {
            case .confirmDelete(let type, let rating):
                let username = rating.user.username
                return Alert(
                    title: Text(type == .mine ? "평가를 정말 삭제하시겠어요?" : "\(username)님의 평가를 정말 삭제하시겠어요?"),
                    message: Text(""),
                    primaryButton: .destructive(Text("삭제")) { performDelete(type: type, rating: rating)},
                    secondaryButton: .cancel(Text("취소"))
                )
            case .deletionSuccess(let type):
                return Alert(
                    title: Text("삭제했습니다."),
                    dismissButton: .default(Text("확인")) {
                        reloadAfterDeletion()
                        if (type == .mine) {
                            viewModel.fetchRatingList()
                        }
                    }
                )
            }
        }
        .fullScreenCover(
            isPresented: $isPresentingEditor,
            onDismiss: {
                viewModel.reloadAllRatings()
            }
        ) {
            RatingEditorView(recipeId: viewModel.recipeId, onComplete: {  })
        }
        .onAppear {
            viewModel.reloadAll()
        }
        .onChange(of: authManager.isLoggedIn) { newValue in
            viewModel.reloadAll()
        }
        .onChange(of: authManager.currentUser) { newValue in
            if case .error = viewModel.ratingSummaryState {
                // currentUser 상태 변경 전, 토큰 만료(세션 만료) 등으로 인해 RatingSummaryState가 .error 였다면, 레시피 요약, 내 평가 섹션, 평가 목록 섹션도 모두 정상적으로 화면에 보여지고 있지 않을 것이기에 전체 데이터를 모두 새로고침합니다.
                viewModel.reloadAllRatings()
            } else {
                viewModel.fetchMyRating()
            }
        }
        .navigationTitle(viewModel.ratings.count > 0 ? "\(viewModel.ratings.count)개의 평가" : "평가")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func reloadAfterDeletion() {
        viewModel.fetchRatingSummary { hasRatings in
            if hasRatings {
                viewModel.fetchMyRating()
            } else {
                viewModel.ratings = []
                viewModel.myRatingState = .loadedNothing
            }
        }
        alert = nil
    }
    
    private func triggerDelete(type: RatingDeleteType, rating: RatingItem) {
        authManager.performAfterLogIn {
            alert = .confirmDelete(type: type, rating: rating)
        }
    }
    
    private func performDelete(type: RatingDeleteType, rating: RatingItem) {
        switch type {
        case .mine:
            viewModel.deleteMyRating(id: rating.id) {
                alert = .deletionSuccess(type: .mine)
            }
        case .other:
            viewModel.deleteRatingItem(id: rating.id) {
                alert = .deletionSuccess(type: .other(username: rating.user.username))
            }
        }
    }

    
    private func registerRatingWithoutAuth() {
        authManager.presentAfterLogIn {
            self.isPresentingEditor = true
        }
//        if authManager.isLoggedIn {
//            self.isPresentingEditor = true
//        } else {
////            authManager.requireAuthWithCompletion(.authRequiredAction(onDismiss: { isLoggedIn in
////                if (isLoggedIn) {
////                    self.isPresentingEditor = true
////                }
////            }))
//        }
        
    }
    
    private func editMyRating() {
        authManager.performAfterLogIn {
            self.isPresentingEditor = true
        }
    }

    private func deleteMyRating(_ rating: RatingItem) {
        authManager.performAfterLogIn {
            ratingToDelete = rating
            deleteType = .mine
            showDeleteRatingAlert = true
        }
    }

    private func canManage() -> Bool {
        guard let currentUsername = authManager.currentUser?.username else { return false }
        return viewModel.recipeEssential?.authorUsername == currentUsername
    }
    
    private func hideRating(_ id: Int64) {
        print("hide rating \(id)")
    }
    
    private func deleteRating(_ rating: RatingItem) {
        triggerDelete(type: .other(username: rating.user.username), rating: rating)
    }
    
}
