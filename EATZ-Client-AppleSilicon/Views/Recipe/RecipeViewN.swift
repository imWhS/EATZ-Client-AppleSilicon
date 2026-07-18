//
//  RecipeViewN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/9/26.
//

// C.C.

import SwiftUI

struct RecipeViewN: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecipeViewModelN()
    
    private let recipeId: Int64
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    @ViewBuilder
    private var recipeView: some View {
        Group {
            switch viewModel.state {
            case .initialLoading: LoadingCurtain(title: "레시피를 불러오고 있어요...")
            case .content(let recipe): RecipeContentView(viewModel, authManager, router, recipe)
            case .error(let message): ErrorCurtain(message, onRetry: { viewModel.load(for: recipeId) })
            }
        }
    }
    
    private var moreMenuToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if viewModel.isCurrentUserAuthor { authorMenuSection }
                else { nonAuthorMenuSection }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    private var authorMenuSection: some View {
        Group {
            Button(action: { viewModel.handleUpdate(recipeId) }) {
                Label("수정", systemImage: "pencil")
            }
            Button(role: .destructive, action: { viewModel.handleDelete(recipeId) }) {
                Label("삭제", systemImage: "trash")
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private var nonAuthorMenuSection: some View {
        Button(action: viewModel.handleReport) {
            Label("신고", systemImage: "exclamationmark.bubble")
        }
        Button(action: viewModel.handleBlockAuthor) {
            Label("작성자 차단", systemImage: "nosign")
        }
    }
    
    var body: some View {
        recipeView
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("레시피")
            .navigationDestination(for: RecipeTag.self) { tag in
                Text("\(tag.name) 태그의 레시피 목록")
                .navigationTitle(tag.name)
            }
            .toolbar {
                if authManager.isLoggedIn {
                    moreMenuToolbarItem
                }
            }
            .task(id: recipeId) {
                viewModel.loadInitial(for: recipeId, authManager.currentUser)
            }
            .onChange(of: authManager.currentUser) { previous, new in viewModel.handleCurrentUserChanged(recipeId, previous, new)}
            .onChange(of: viewModel.routingAction) { _, routingAction in
                switch routingAction {
                case .dismiss: dismiss.callAsFunction()
                case .none: break } }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: isAlertPresented(),
                presenting: viewModel.alert,
                actions: { $0.actions },
                message: { $0.message })
            .sheet(
                item: $viewModel.sheet,
                onDismiss: { viewModel.loadQuietly(for: recipeId) },
                content: buildSheet)
            .fullScreenCover(
                item: $viewModel.fullScreenCover,
                onDismiss: { viewModel.loadQuietly(for: recipeId) },
                content: buildFullScreenCover)
            .getBlockContext(targetUser: $viewModel.blockTargetUser, onSuccess: { self.dismiss(); })
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private func buildSheet(item: RecipeSheet) -> some View {
        switch item {
        case .plannerDatePicker(let recipeId): PlannerDatePicker(for: recipeId)
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(item: RecipeFullScreenCover) -> some View {
        switch item {
        case .recipeEditor: RecipeEditor(mode: .update(recipeId)) {}
        case .recipeWebPageView(let recipeUrl): RecipeWebPageView(recipeUrl: recipeUrl)
        }
    }
    
    private func isAlertPresented() -> Binding<Bool> {
        return Binding(
            get: { self.viewModel.alert != nil },
            set: { isPresented in if !isPresented { self.viewModel.alert = nil } } )
    }
}

enum RecipeAlert {
    case confirmAddingAllRequirementsToPantry(
        ingredientsCount: Int, kitchenwaresCount: Int, confirmAction: () -> Void)
    case addedAllRequirementsToPantry(completion: () -> Void)
    case confirmDelete(confirmAction: () -> Void)
    case deleted(dismissAction: () -> Void)
    case toggleLikeFailed(message: String)
    case toggleSaveFailed(message: String)
    case addKitchenwareFailed(message: String)
    case removeKitchenwareFailed(message: String)
    case addIngredientFailed(message: String)
    case removeIngredientFailed(message: String)
    case likeIngredientFailed(message: String)
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmAddingAllRequirementsToPantry: return "모두 보관함에 추가"
        case .addedAllRequirementsToPantry: return "모두 보관함에 추가 완료"
        case .confirmDelete: return "레시피 삭제"
        case .deleted: return "레시피 삭제 완료"
        case .toggleLikeFailed: return "좋아요 실패"
        case .toggleSaveFailed: return "저장 실패"
        case .addKitchenwareFailed: return "도구 추가 실패"
        case .removeKitchenwareFailed: return "도구 제거 실패"
        case .addIngredientFailed: return "재료 추가 실패"
        case .removeIngredientFailed: return "재료 제거 실패"
        case .likeIngredientFailed: return "재료 좋아요 실패"
        case .error: return "오류"
        }
    }

    var message: some View {
        switch self {
        case .confirmAddingAllRequirementsToPantry(let ingredientsCount, let kitchenwaresCount, _):
            let missingRequirementsLabel = createMissingRequirementsLabel(ingredientsCount, kitchenwaresCount)
            return Text("이 레시피를 요리하기 위해 부족한 \(missingRequirementsLabel)를 회원님의 보관함에 추가할까요?")
        case .addedAllRequirementsToPantry: return Text("모든 재료와 도구를 보관함에 추가했어요.")
        case .confirmDelete: return Text("지금 보고 계신 레시피를 삭제할까요? 삭제된 레시피는 복구할 수 없어요.")
        case .deleted: return Text("레시피를 삭제했어요.")
        case .toggleLikeFailed(let message): return Text(message)
        case .toggleSaveFailed(let message): return Text(message)
        case .addKitchenwareFailed(let message): return Text(message)
        case .removeKitchenwareFailed(let message): return Text(message)
        case .addIngredientFailed(let message): return Text(message)
        case .removeIngredientFailed(let message): return Text(message)
        case .likeIngredientFailed(let message): return Text(message)
        case .error(let message): return Text(message)
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmAddingAllRequirementsToPantry(_, _, let confirmAction):
            Button("취소", role: .cancel) {}
            Button("모두 보관함에 추가", action: confirmAction).keyboardShortcut(.defaultAction)
        case .addedAllRequirementsToPantry(let completion): Button("확인", role: .cancel, action: completion)
        case .confirmDelete(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: confirmAction)
        case .deleted(let dismissAction): Button("확인", action: dismissAction)
        case .toggleLikeFailed: Button("확인", role: .cancel) {}
        case .toggleSaveFailed: Button("확인", role: .cancel) {}
        case .addKitchenwareFailed: Button("확인", role: .cancel) {}
        case .removeKitchenwareFailed: Button("확인", role: .cancel) {}
        case .addIngredientFailed: Button("확인", role: .cancel) {}
        case .removeIngredientFailed: Button("확인", role: .cancel) {}
        case .likeIngredientFailed: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    private func createMissingRequirementsLabel(_ ingredientsCount: Int, _ kitchenwaresCount: Int) -> String {
        var labelItems: [String] = []
        if 0 < kitchenwaresCount { labelItems.append("도구 \(kitchenwaresCount)개") }
        if 0 < ingredientsCount { labelItems.append("재료 \(ingredientsCount)개") }
        
        return labelItems.joined(separator: "와 ")
    }
}

enum RecipeSheet: Identifiable {
    case plannerDatePicker(recipeId: Int64)
    
    var id: String {
        switch self {
        case .plannerDatePicker(let recipeId): return "plannerDatePicker-\(recipeId)"
        }
    }
}

enum RecipeFullScreenCover: Identifiable {
    case recipeEditor(mode: RecipeEditorMode)
    case recipeWebPageView(url: URL)
    
    var id: String {
        switch self {
        case .recipeEditor(let mode): return "plannerDatePicker-\(mode)"
        case .recipeWebPageView(let url): return "recipeWebPageView-\(url.absoluteString)"
        }
    }
}
