//
//  RatingContentView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/11/26.
//

import SwiftUI

struct RatingContentView: View {
    @ObservedObject private var authManager: AuthManager
    @ObservedObject private var viewModel: RatingViewModelN
    private let recipeEssential: RecipeEssentialWithAuthor
    private let pagedRatings: Paged<RatingWithPermissions>
    private let recipeId: Int64
    
    init(
        _ authManager: AuthManager,
        _ viewModel: RatingViewModelN,
        _ recipeEssential: RecipeEssentialWithAuthor,
        _ pagedRatings: Paged<RatingWithPermissions>,
        _ recipeId: Int64
    ) {
        self.authManager = authManager
        self.viewModel = viewModel
        self.recipeEssential = recipeEssential
        self.pagedRatings = pagedRatings
        self.recipeId = recipeId
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if 0 < pagedRatings.totalElements {
                ScrollView {
                    VStack(spacing: 0) {
                        RecipeEssentialView(recipeEssential, .gray)
                        RatingIndicatorView(state: viewModel.indicatorState)
                        userContextView
                        RatingList(
                            pagedRatings: pagedRatings,
                            loadMore: { viewModel.loadMoreRatings(currentUser: authManager.currentUser, recipeId: recipeId) },
                            onDelete: { type in viewModel.handleDelete(type, recipeId) },
                            onBlock: viewModel.handleBlockUser,
                            onReport: viewModel.handleReportRating,
                            onHide: { _ in }) }
                }
            } else {
                emptyStateView
            }
        }
    }
    
    private var userContextView: some View {
        VStack(spacing: 20) {
            RatingSectionCommonHeaderView(title: "내 평가")
            if let currentUser = authManager.currentUser {
                RatingMyView(
                    username: currentUser.username,
                    userImageUrl: currentUser.imageUrl,
                    state: viewModel.myState,
                    onRegisterTapped: { viewModel.presentEditor(for: recipeId, mode: .create) },
                    onUpdateTapped: { id in viewModel.presentEditor(for: recipeId, mode: .update) },
                    onDeleteTapped: { rating in viewModel.handleDelete(.mine(rating), recipeId) })
            } else {
                RatingGuestView(onLogIn: authManager.requireAuthView)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            RecipeEssentialView(recipeEssential)
            RatingEmptyView(
                isLoggedIn: authManager.isLoggedIn,
                onRegisterTapped: handleRegisterTapped)
        }
    }
    
    private func handleRegisterTapped(isLoggedIn: Bool) {
        authManager.performWhenLoggedIn {
            viewModel.presentEditor(for: recipeId, mode: .create)
        }
    }
}
