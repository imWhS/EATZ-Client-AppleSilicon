////
////  RatingView.swift
////  EATZ-Client-AppleSilicon
////
////  Created by 손원희 on 5/24/25.
////
//
//import SwiftUI
//
//struct RatingView: View {
//    @EnvironmentObject private var authManager: AuthManager
//    @StateObject var viewModel: RatingViewModel
//
//    init(recipeId: Int64) {
//        _viewModel = StateObject(wrappedValue: RatingViewModel(for: recipeId))
//    }
//    
//    @ViewBuilder
//    private var ratingView: some View {
//        Group {
//            if viewModel.isEmptyState { emptyStateView }
//            else { mainContentView }
//        }
//    }
//    
//    private var mainContentView: some View {
//        ScrollView {
//            VStack(spacing: 0) {
//                recipeEssentialWrapperView
//                RatingScoreSummaryView(state: viewModel.indicatorState)
//                MyRatingView(
//                    currentUser: authManager.currentUser,
//                    state: viewModel.myRatingState,
//                    onRegisterTapped: { viewModel.presentEditorView(mode: .create) },
//                    onUpdateTapped: { viewModel.presentEditorView(mode: .update(ratingId: rating)) },
//                    onDeleteTapped: { rating in viewModel.handleDelete(type: .mine(rating: rating)) },
//                    onLogIn: authManager.requireAuthView)
//                RatingList(
//                    pagedRatings: viewModel.pagedRatings,
//                    onLoadMore: viewModel.loadMoreRatingList,
//                    onDelete: viewModel.handleDelete,
//                    onHide: viewModel.hideRating)
//            }
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 0) {
//            recipeEssentialWrapperView
//            RatingEmptyView(
//                isLoggedIn: authManager.isLoggedIn,
//                onRegister: { viewModel.presentEditorView(mode: .create) })
//        }
//    }
//    
//    @ViewBuilder
//    private var recipeEssentialWrapperView: some View {
//        if let recipeEssential = viewModel.recipeEssential {
//            RecipeEssentialView(recipeEssential)
//        } else {
//            EmptyView()
//        }
//    }
//    
//    var body: some View {
//        ratingView
//        .navigationTitle(viewModel.navigationTitleLabel)
//        .navigationBarTitleDisplayMode(.inline)
//        .task(id: authManager.currentUser) {
//            viewModel.authManager = authManager
//            viewModel.prepareDataIfNeeded()
//        }
//        .refreshable { await viewModel.refresh() }
//        .alert(
//            viewModel.alert?.title ?? "",
//            isPresented: Binding(
//                get: { self.viewModel.alert != nil },
//                set: { isPresented in if !isPresented { self.viewModel.alert = nil } }),
//            presenting: viewModel.alert,
//            actions: { $0.actions },
//            message: { $0.message })
//        .fullScreenCover(
//            item: $viewModel.fullScreenCover,
//            onDismiss: viewModel.prepareDataIfNeeded,
//            content: buildFullScreenCover)
//    }
//    
//    @ViewBuilder
//    private func buildFullScreenCover(for type: RatingFullScreenCover) -> some View {
//        switch type {
//        case .ratingEditor(let recipeId, let mode): RatingEditor(recipeId: recipeId, mode: mode)
//        }
//    }
//}
