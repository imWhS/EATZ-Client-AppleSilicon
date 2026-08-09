//
//  SavedRecipesListView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/31/25.
//

import SwiftUI

struct SavedRecipesView: View {
    @StateObject private var viewModel = RecipeBasicListViewModel(fetcher: { page, completion in
        UserService.shared.fetchSavedRecipes(page: page, completion: completion)
    })
    
    @State private var alert: SavedRecipesAlert?
    @State private var sheet: SavedRecipesSheet?
    @State private var fullScreenCover: SavedRecipesFullScreenCover?
    @State private var reportResource: ReportResource?
    
    var body: some View {
        RecipeBasicPagedList(
            viewModel,
            navigationTitleLabel: "저장한 레시피",
            emptyView: emptyView,
            menuContent: { recipe in
                RecipeBasicCommonActionMenuView(
                    recipe: recipe,
                    currentUser: viewModel.currentUser,
                    onUpdateTapped: { self.fullScreenCover = .recipeEditor(mode: .update(recipe.id)) },
                    onDeleteTapped: { self.alert = .confirmDelete(confirmAction: { self.deleteRecipe(for: recipe.id) }) },
                    onToggleSaveTapped: { self.toggleSaveRecipe(recipe) },
                    onAddToPlannerTapped: { self.sheet = .addToPlanner(for: recipe.id) },
                    onReportTapped: { self.handleReportRecipe(for: recipe) }
                )
            }
        )
        .background(Color.backgroundPrimary)
        .alert(item: $alert) { $0.alert }
        .sheet(item: $sheet, content: buildSheet)
        .fullScreenCover(
            item: $fullScreenCover,
            onDismiss: viewModel.prepareDataIfNeeded,
            content: buildFullScreenCover)
        .getReportContext(resource: $reportResource)
    }
    
    @ViewBuilder
    private func buildSheet(for type: SavedRecipesSheet) -> some View {
        switch type {
        case .addToPlanner(let recipeId): PlannerDatePicker(for: recipeId)
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(for type: SavedRecipesFullScreenCover) -> some View {
        switch type {
        case .recipeEditor(let mode):
            RecipeEditor(
                mode: mode,
                onSubmitCompleted: viewModel.prepareDataIfNeeded
            )
        }
    }
    
    private func emptyView() -> some View {
        CommonEmptyStateView(
            title: "저장한 레시피가 없어요.",
            "둘러보기, 레시피 화면 등에서 저장한 레시피가 여기에 나타나요.",
            "save-40"
        )
    }
    
    private func deleteRecipe(for id: Int64) {
        RecipeService.shared.delete(for: id) { result in
            switch result {
            case .success:
                self.alert = .deletionSuccess
                self.viewModel.removeRecipe(for: id)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func toggleSaveRecipe(_ recipe: RecipeBasic) {
        if recipe.savedByUser { unsaveRecipe(for: recipe.id) }
        else { saveRecipe(for: recipe.id) }
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
                self.viewModel.removeRecipe(for: id)
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

enum SavedRecipesFullScreenCover: Identifiable {
    case recipeEditor(mode: RecipeEditorMode)
    
    var id: String {
        switch self {
        case .recipeEditor(let mode): return "recipeEditor-\(mode == .create ? "create" : "update")"
        }
    }
}

enum SavedRecipesSheet: Identifiable {
    case addToPlanner(for: Int64)
    
    var id: String {
        switch self {
        case .addToPlanner(let recipeId):
            return "addToPlanner-\(recipeId)"
        }
    }
}

enum SavedRecipesAlert: Identifiable {
    case confirmDelete(confirmAction: () -> Void)
    case deletionSuccess
    case saveSuccess
    case unsaveSuccess
    case error(message: String)
    
    var id: String {
        switch self {
        case .confirmDelete: return "confirmDelete"
        case .deletionSuccess: return "deletionSuccess"
        case .saveSuccess: return "saveSuccess"
        case .unsaveSuccess: return "unsaveSuccess"
        case .error(let message): return "error-\(message)"
        }
    }
    
    var alert: Alert {
        switch self {
        case .confirmDelete(let confirmAction):
            return Alert(
                title: Text("레시피 삭제"),
                message: Text("레시피를 삭제할까요? 삭제된 레시피는 복구할 수 없어요."),
                primaryButton: .destructive(Text("삭제"), action: confirmAction),
                secondaryButton: .cancel(Text("취소"))
            )
        case .deletionSuccess:
            return Alert(
                title: Text("레시피 삭제 완료"),
                message: Text("레시피를 삭제했어요."),
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
