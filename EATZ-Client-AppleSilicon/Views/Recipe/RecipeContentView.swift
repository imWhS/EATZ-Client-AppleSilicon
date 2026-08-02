//
//  RecipeContentView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/9/26.
//

import SwiftUI

struct RecipeContentView: View {
    @ObservedObject private var authManager: AuthManager
    @ObservedObject var viewModel: RecipeViewModelN
    @ObservedObject private var router: Router
    
    @State private var scrollOffset: CGPoint = .zero
    @State private var selectedTag: RecipeTag?
    
    let recipe: Recipe
    
    init(_ viewModel: RecipeViewModelN,
         _ authManager: AuthManager,
         _ router: Router,
         _ recipe: Recipe) {
        self.authManager = authManager
        self.viewModel = viewModel
        self.router = router
        self.recipe = recipe
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RecipeContentImageView(recipe.imageUrl)
                infoSection
                requirementsSection
            }
            .trackOffset(into: $scrollOffset)
        }
        .ignoresSafeArea(edges: .top)
        .refreshable { await viewModel.refresh(for: recipe.id) }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            basicSection
            detailSection
        }
    }
    
    private var basicSection: some View {
        VStack(spacing: 0) {
            RecipeDetailSummarySection(recipe: recipe)
            RecipeDetailInteractionBar(
                likedCount: recipe.likedCount,
                isLiked: recipe.liked,
                isSaved: recipe.saved,
                onLikeTapped: handleToggleLikeTapped,
                onAddToPlannerTapped: handleAddToPlannerTapped,
                onToggleSaveTapped: handleToggleSaveTapped,
                onShowRecipeTapped: viewModel.showRecipe)
        }
        .padding(.vertical, 10)
    }
    
    private var detailSection: some View {
        VStack(spacing: 0) {
            RecipeDetailInfoDescriptionView(
                description: recipe.description,
                createdAt: recipe.createdAt,
                authorUsername: recipe.author.username,
                authorImageUrl: recipe.author.imageUrl,
                authorBio: recipe.author.bio,
                creatorName: recipe.creatorName,
                creatorUrl: recipe.creatorUrl
            )
            RecipeDetailInfoReactionView(
                recipe.id,
                ratingSummary: recipe.ratingIndicatorSummary,
                commentCount: recipe.commentCount,
                commentEnabled: recipe.commentEnabled,
                onRatingTapped: handleRatingTapped,
                onCommentTapped: handleCommentTapped)
        }
    }
    
    @ViewBuilder
    private var requirementsSection: some View {
        switch viewModel.requirementsState {
        case .idle: Color.clear.frame(height: 1).task { viewModel.loadRequirementsIfNeeded(for: recipe.id) }
        case .loading: LoadingCurtain(title: "레시피가 요구하는 도구와 재료를 불러오고 있어요...")
        case .content(let kitchenwares, let ingredients, let cookability):
            RecipeRequirementContentView(
                isMember: authManager.isLoggedIn,
                kitchenwares: kitchenwares,
                ingredients: ingredients,
                cookability: cookability,
                onShowRecipeTapped: viewModel.showRecipe,
                onAuth: authManager.requireAuthView,
                onAddAllRequirements: viewModel.handleAddAllRequirementsToPantry,
                onRequirementsAction: viewModel.handleRequirementsAction)
        case .error(let message): ErrorCurtain(message, onRetry: { viewModel.load(for: recipe.id) })
        }
    }
    
    private func handleRatingTapped(recipeId: Int64) { router.push(.rating(recipeId: recipeId)) }
    
    private func handleCommentTapped(recipeId: Int64) { router.push(.comment(recipeId: recipeId)) }
    
    private func handleToggleLikeTapped() {
        authManager.performWhenLoggedIn {
            viewModel.toggleLike(for: recipe.id)
        }
    }
    
    private func handleToggleSaveTapped() {
        authManager.performWhenLoggedIn {
            viewModel.toggleSave(for: recipe.id)
        }
    }
    
    private func handleAddToPlannerTapped() {
        authManager.performWhenLoggedIn {
            viewModel.presentPlannerDatePicker(for: recipe.id)
        }
    }
}
