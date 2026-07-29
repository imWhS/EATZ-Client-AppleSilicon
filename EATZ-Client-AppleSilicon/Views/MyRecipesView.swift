//
//  MyRecipesView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/31/25.
//

import SwiftUI

struct MyRecipesView: View {
    @StateObject private var viewModel = RecipeBasicListViewModel(fetcher: { page, completion in
        UserService.shared.fetchMyRecipes(page: page, completion: completion)
    })
    
    @State private var alert: MyRecipesAlert?
    @State private var sheet: MyRecipesSheet?
    @State private var fullScreenCover: MyRecipesFullScreenCover?
    
    var body: some View {
        RecipeBasicPagedList(
            viewModel,
            navigationTitle: "내 레시피",
            emptyView: {
                Curtain(
                    title: "등록한 레시피가 없어요.",
                    actionTitle: "새 레시피",
                    action: { self.fullScreenCover = .recipeEditor(mode: .create) },
                    footer: {
                        Text("새 레시피를 등록해볼까요?")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray35)
                    }
                )
            },
            menuContent: { recipe in
                RecipeBasicCommonActionMenuView(
                    recipe: recipe,
                    currentUser: viewModel.currentUser,
                    onUpdateTapped: { self.fullScreenCover = .recipeEditor(mode: .update(recipe.id)) },
                    onDeleteTapped: { self.alert = .confirmDelete(confirmAction: { self.deleteRecipe(id: recipe.id) }) },
                    onToggleSaveTapped: { self.toggleSaveRecipe(recipe: recipe) },
                    onAddToPlannerTapped: { self.sheet = .addToPlanner(recipeId: recipe.id) },
                    onReportTapped: {  }
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
    }
    
    @ViewBuilder
    private func buildSheet(for type: MyRecipesSheet) -> some View {
        switch type {
        case .addToPlanner(let recipeId): PlannerDatePicker(for: recipeId)
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(type: MyRecipesFullScreenCover) -> some View {
        switch type {
        case .recipeEditor(let mode):
            RecipeEditor(
                mode: mode,
                onSubmitCompleted: viewModel.prepareDataIfNeeded
            )
        }
    }
    
    private func deleteRecipe(id: Int64) {
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
    
    private func toggleSaveRecipe(recipe: RecipeBasic) {
        if recipe.savedByUser {
            unsaveRecipe(id: recipe.id)
        } else {
            saveRecipe(id: recipe.id)
        }
    }
    
    private func saveRecipe(id: Int64) {
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
    
    private func unsaveRecipe(id: Int64) {
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
}

enum MyRecipesFullScreenCover: Identifiable {
    case recipeEditor(mode: RecipeEditorMode)
    
    var id: String {
        switch self {
        case .recipeEditor(_): return "recipeEditor"
        }
    }
}

enum MyRecipesSheet: Identifiable {
    case addToPlanner(recipeId: Int64)
    
    var id: String {
        switch self {
        case .addToPlanner(let recipeId): return "addToPlanner-\(recipeId)"
        }
    }
}

enum MyRecipesAlert: Identifiable {
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
