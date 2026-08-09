//
//  RatedRecipesView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/31/25.
//

import SwiftUI

struct RatedRecipesView: View {
    @StateObject private var viewModel = RecipeBasicListViewModel(fetcher: { page, completion in
        UserService.shared.fetchRatedRecipes(page: page, completion: completion)
    })
    
    @State private var alert: RatedRecipesAlert?
    @State private var sheet: RatedRecipesSheet?
    @State private var fullScreenCover: RatedRecipesFullScreenCover?
    @State private var reportResource: ReportResource?
    
    var body: some View {
        RecipeBasicPagedList(
            viewModel,
            navigationTitleLabel: "평가한 레시피",
            emptyView: emptyView,
            menuContent: { recipe in
                RecipeBasicCommonActionMenuView(
                    recipe: recipe,
                    currentUser: viewModel.currentUser,
                    onUpdateTapped: { self.fullScreenCover = .recipeEditor(mode: .update(recipe.id)) },
                    onDeleteTapped: { self.alert = .confirmDeleteRecipe(confirmAction: { self.deleteRecipe(id: recipe.id) }) },
                    onToggleSaveTapped: { self.toggleSaveRecipe(recipe: recipe) },
                    onAddToPlannerTapped: { self.sheet = .addToPlanner(recipeId: recipe.id) },
                    onReportTapped: { self.handleReportRecipe(for: recipe) }
                ) { self.additionalActionMenu(recipe: recipe) }
            }
        )
        .background(Color.backgroundPrimary)
        .alert(item: $alert) { item in item.alert }
        .sheet(item: $sheet, content: buildSheet)
        .fullScreenCover(
            item: $fullScreenCover,
            onDismiss: viewModel.prepareDataIfNeeded,
            content: buildFullScreenCover)
        .getReportContext(resource: $reportResource)
    }
    
    @ViewBuilder
    private func buildSheet(for type: RatedRecipesSheet) -> some View {
        switch type {
        case .addToPlanner(let recipeId): PlannerDatePicker(for: recipeId)
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(type: RatedRecipesFullScreenCover) -> some View {
        switch type {
        case .recipeEditor(let mode):
            RecipeEditor(
                mode: mode,
                onSubmitCompleted: viewModel.prepareDataIfNeeded
            )
        case .ratingEditor(let recipeId, let mode):
            RatingEditor(recipeId: recipeId, mode: mode, onSubmitCompleted: viewModel.prepareDataIfNeeded)
        }
    }
    
    func emptyView() -> some View {
        CommonEmptyStateView(
            title: "평가한 레시피가 없어요.",
            "레시피 평가 화면에서 평가한 레시피가 여기에 나타나요.",
            "rating-star-40"
        )
    }
    
    @ViewBuilder
    private func additionalActionMenu(recipe: RecipeBasic) -> some View {
        Button(action: { fullScreenCover = .ratingEditor(recipeId: recipe.id, mode: .update) }) {
            Label("평가 수정", systemImage: "pencil")
        }
        Button(role: .destructive, action: { alert = .confirmDeleteRating(confirmAction: { self.deleteRating(for: recipe.id) }) }) {
            Label("평가 삭제", systemImage: "pencil")
        }
    }
    
    private func deleteRating(for id: Int64) {
        RecipeService.shared.delete(for: id) { result in
            switch result {
            case .success:
                self.alert = .deletionRecipeSuccess
                self.viewModel.removeRecipe(for: id)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func deleteRecipe(id: Int64) {
        RecipeService.shared.delete(for: id) { result in
            switch result {
            case .success:
                self.alert = .deletionRecipeSuccess
                self.viewModel.removeRecipe(for: id)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func toggleSaveRecipe(recipe: RecipeBasic) {
        if recipe.savedByUser {
            unsaveRecipe(for: recipe.id)
        } else {
            saveRecipe(for: recipe.id)
        }
    }
    
    private func saveRecipe(for id: Int64) {
        UserService.shared.saveRecipe(for: id) { result in
            switch result {
            case .success:
                self.alert = .saveSuccess
                self.viewModel.toggleSavedState(for: id)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func unsaveRecipe(for id: Int64) {
        UserService.shared.unsaveRecipe(for: id) { result in
            switch result {
            case .success:
                self.alert = .unsaveSuccess
                self.viewModel.toggleSavedState(for: id)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func handleReportRecipe(for recipe: RecipeBasic) {
        reportResource = ReportResource(
            id: recipe.id,
            authorId: recipe.authorId,
            authorUsername: recipe.authorUsername,
            type: .RECIPE,
            content: recipe.title)
    }
}

enum RatedRecipesFullScreenCover: Identifiable {
    case ratingEditor(recipeId: Int64, mode: RatingEditorMode)
    case recipeEditor(mode: RecipeEditorMode)
    
    var id: String {
        switch self {
        case .ratingEditor(let recipeId, let mode):
            return "ratingEditor-\(recipeId)-\(mode == .create ? "create" : "update")"
        case .recipeEditor(_):
            return "recipeEditor"
        }
    }
}


enum RatedRecipesSheet: Identifiable {
    case addToPlanner(recipeId: Int64)
    
    var id: String {
        switch self {
        case .addToPlanner(let recipeId):
            return "addToPlanner-\(recipeId)"
        }
    }
}

enum RatedRecipesAlert: Identifiable {
    case confirmDeleteRecipe(confirmAction: () -> Void)
    case confirmDeleteRating(confirmAction: () -> Void)
    case deletionRecipeSuccess
    case deletionRatingSuccess
    case saveSuccess
    case unsaveSuccess
    case error(message: String)
    
    var id: String {
        switch self {
        case .confirmDeleteRecipe: return "confirmDelete"
        case .confirmDeleteRating: return "confirmDeleteRating"
        case .deletionRecipeSuccess: return "deletionRecipeSuccess"
        case .deletionRatingSuccess: return "deletionRatingSuccess"
        case .saveSuccess: return "saveSuccess"
        case .unsaveSuccess: return "unsaveSuccess"
        case .error(let message): return "error-\(message)"
        }
    }
    
    var alert: Alert {
        switch self {
        case .confirmDeleteRecipe(let confirmAction):
            return Alert(
                title: Text("레시피 삭제"),
                message: Text("레시피를 정말 삭제할까요? 삭제된 레시피는 복구할 수 없어요."),
                primaryButton: .destructive(Text("삭제"), action: confirmAction),
                secondaryButton: .cancel(Text("취소"))
            )
        case .confirmDeleteRating(let confirmAction):
            return Alert(
                title: Text("평가 삭제"),
                message: Text("평가를 정말 삭제할까요? 삭제된 평가는 복구할 수 없어요."),
                primaryButton: .destructive(Text("삭제"), action: confirmAction),
                secondaryButton: .cancel(Text("취소"))
            )
        case .deletionRecipeSuccess:
            return Alert(
                title: Text("레시피 삭제 완료"),
                message: Text("레시피를 삭제했어요."),
                dismissButton: .default(Text("확인"))
            )
        case .deletionRatingSuccess:
            return Alert(
                title: Text("평가 삭제 완료"),
                message: Text("평가를 삭제했어요."),
                dismissButton: .default(Text("확인"))
            )
        case .saveSuccess:
            return Alert(
                title: Text("레시피 저장 완료"),
                message: Text("레시피를 저장했어요."),
                dismissButton: .default(Text("확인"))
            )
        case .unsaveSuccess:
            return Alert(
                title: Text("레시피 저장 취소 완료"),
                message: Text("레시피를 저장 취소했어요."),
                dismissButton: .default(Text("확인"))
            )
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
