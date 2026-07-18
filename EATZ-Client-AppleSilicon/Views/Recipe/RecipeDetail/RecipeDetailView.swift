//
//  RecipeDetailView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/16/25.
//

import SwiftUI
import Kingfisher

struct RecipeDetailView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    
    @State private var scrollOffset: CGPoint = .zero
    @State private var selectedTag: RecipeTag?
    
    let router: Router
    
    var body: some View {
        viewStateContent
    }
    
    @ViewBuilder
    private var viewStateContent: some View {
        if let detailState = viewModel.detailState { mainContent(detailState) }
        else { ProgressView() }
    }
    
    private func mainContent(_ detailState: RecipeDetailState) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RecipeContentImageView(detailState.recipe.imageUrl)
                LazyVStack(alignment: .leading, spacing: 0) {
                    RecipeDetailEssentialSection(
                        detailState: detailState,
                        onLikeTapped: viewModel.handleToggleLike,
                        onAddToPlannerTapped: viewModel.presentCalendar,
                        onToggleSaveTapped: viewModel.handleToggleSave,
                        onShowRecipeTapped: viewModel.handleShowRecipe)
                    RecipeDetailInfoSection(
                        recipe: detailState.recipe,
                        onRatingTapped: handleRatingTapped,
                        onCommentTapped: handleCommentTapped)
                    RecipeDetailRequirementsView(viewModel: viewModel.requirementsViewModel)
                }
            }
            .trackOffset(into: $scrollOffset)
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("레시피")
        .navigationDestination(for: RecipeTag.self) { tag in
            Text("\(tag.name) 태그의 레시피 목록")
            .navigationTitle(tag.name)
        }
        .refreshable { await viewModel.refresh() }
    }
    
    private func handleRatingTapped(recipeId: Int64) { router.push(.rating(recipeId: recipeId)) }
    
    private func handleCommentTapped(recipeId: Int64) { router.push(.comment(recipeId: recipeId)) }
}

