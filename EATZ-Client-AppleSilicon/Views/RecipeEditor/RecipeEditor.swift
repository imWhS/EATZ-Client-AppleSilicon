//
//  RecipeEditor.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/18/25.
//

import SwiftUI

struct RecipeEditor: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecipeEditorViewModel()
    
    private let mode: RecipeEditorMode
    private let onSubmitCompleted: () -> Void
    
    init(mode: RecipeEditorMode, onSubmitCompleted: @escaping () -> Void) {
        self.mode = mode
        self.onSubmitCompleted = onSubmitCompleted
    }
    
    private var recipeEditor: some View {
        Group {
            switch viewModel.state {
            case .initialLoading: LoadingCurtain(title: "레시피를 편집하기 위해 준비하고 있어요...")
            case .content: contentView
            case .error(let message): ErrorCurtain(message, onRetry: { viewModel.load(authManager) })
            case .unauthorized: CommonUnauthorizedStateView()
            }
        }
        .disabled(viewModel.submissionState == .submitting)
    }
    
    var body: some View {
        NavigationView {
            recipeEditor
                .navigationTitle(viewModel.navigationTitleLabel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { cancelToolbarItem; doneToolbarItem }
        }
        .task {
            if viewModel.currentUser == nil {
                viewModel.currentUser = authManager.currentUser
            }
            
            viewModel.loadInitial(mode, authManager)
        }
        .onChange(of: viewModel.selectedPhotoItem) { viewModel.handlePhotoSelection() }
        .onChange(of: authManager.currentUser) { _, newUser in
            viewModel.validateAndPrepareUser(authManager)
        }
        .onChange(of: viewModel.routingAction) { _, routingAction in
            switch routingAction {
            case .dismiss: dismiss.callAsFunction()
            case .submitCompleted:
                onSubmitCompleted()
                dismiss.callAsFunction()
            case .none: break
            }
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: isAlertPresented(),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .sheet(item: $viewModel.sheet) { buildSheet(for: $0) }
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RecipeEditorDefaultInfoSection(
                    draft: $viewModel.currentDraft,
                    localImage: $viewModel.localImage,
                    selectedPhotoItem: $viewModel.selectedPhotoItem,
                    isProcessingImage: $viewModel.isProcessingImage,
                    onDeletePhotoTapped: viewModel.handleClearImage
                )
                RecipeEditorRequirementsSection(
                    draft: $viewModel.currentDraft,
                    onShowKitchenwarePicker: { viewModel.sheet = .kitchenwarePicker },
                    onShowIngredientPicker: { viewModel.sheet = .ingredientPicker })
                RecipeEditorTagsSection(
                    draft: $viewModel.currentDraft,
                    onShowTagPicker: { viewModel.sheet = .tagPicker })
                RecipeEditorOtherOptionsSection(
                    draft: $viewModel.currentDraft,
                    timeSummaryLabel: viewModel.timeSummaryLabel,
                    servingsLabel: viewModel.servingsLabel,
                    creatorSummaryLabel: viewModel.creatorSummaryLabel,
                    onShowTimePicker: { viewModel.sheet = .timePicker },
                    onShowServingsPicker: { viewModel.sheet = .servingsPicker },
                    onShowCreatorInfoEditor: { viewModel.sheet = .creatorInfoEditor }
                )
            }
        }
    }
    
    @ViewBuilder
    private func buildSheet(for type: RecipeEditorSheet) -> some View {
        switch type {
        case .ingredientPicker:
            IngredientPicker(initialSelection: $viewModel.currentDraft.ingredients)
        case .kitchenwarePicker:
            KitchenwarePicker(initialSelection: $viewModel.currentDraft.kitchenwares)
        case .tagPicker:
            TagAdditionView { selection in
                switch selection {
                case .existing(let tagName):
                    // 이미 등록되어 있는 태그인 경우: 이름만 목록에 추가합니다.
                    viewModel.currentDraft.tagNames.append(tagName)
                case .new(let tagName):
                    // 새로운 태그인 경우: 이름만 목록에 추가합니다.
                    viewModel.currentDraft.tagNames.append(tagName)
                }
            }
        case .timePicker:
            RecipeTimePicker(
                // 뷰 모델의 현재 시간 값을 초기 값으로 전달합니다.
                cookingTime: viewModel.currentDraft.cookingTime,
                prepTime: viewModel.currentDraft.prepTime
            ) { newCookingTime, newPrepTime in
                // 뷰 모델의 현재 시간 값을 업데이트합니다.
                viewModel.currentDraft.cookingTime = newCookingTime
                viewModel.currentDraft.prepTime = newPrepTime
            }
        case .servingsPicker:
            ServingsPicker(
                servings: viewModel.currentDraft.servings ?? 0
            ) { newServings in
                viewModel.currentDraft.servings = newServings
            }
        case .creatorInfoEditor:
            RecipeCreatorInfoEditor(
                name: $viewModel.currentDraft.creatorName,
                url: $viewModel.currentDraft.creatorUrl)
        }
    }
    
    private func isAlertPresented() -> Binding<Bool> {
        return Binding(
            get: { self.viewModel.alert != nil },
            set: { isPresented in if !isPresented { self.viewModel.alert = nil } } )
    }
    
    private var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.handleDismissAction()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.submissionState == .submitting {
                ProgressView()
            } else {
                Button("완료", action: viewModel.handleSubmit)
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isSubmittable || viewModel.state != .content)
            }
        }
    }
}

enum RecipeEditorSheet: Identifiable {
    case ingredientPicker
    case kitchenwarePicker
    case tagPicker
    case timePicker
    case servingsPicker
    case creatorInfoEditor
    
    var id: Int { hashValue }
}

enum RecipeEditorAlert: Identifiable {
    case deleteImageConfirmation(confirmAction: () -> Void)
    case hasUnsavedChanges(confirmAction: () -> Void)
    case incompleteDraft(message: String)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(title: String? = nil, message: String)
    
    var id: String {
        switch self {
        case .deleteImageConfirmation: return "deleteImageConfirmation"
        case .hasUnsavedChanges: return "hasUnsavedChanges"
        case .incompleteDraft: return "incompleteDraft"
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .error(let title, let message): return "error\((title == nil) ? "-\(title)" : "")-\(message)"
        }
    }
    
    var title: String {
        switch self {
        case .deleteImageConfirmation: return "대표 사진 삭제"
        case .hasUnsavedChanges: return "변경 사항 존재"
        case .incompleteDraft: return "필수 항목 누락"
        case .userChanged: return "사용자 변경"
        case .sessionExpired: return "세션 만료"
        case .error(let title, _): return title ?? "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .deleteImageConfirmation(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: confirmAction)
        case .hasUnsavedChanges(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive, action: confirmAction)
        case .incompleteDraft: Button("확인", role: .cancel) {}
        case .userChanged(let dismissAction): Button("확인", action: dismissAction)
        case .sessionExpired(let dismissAction): Button("확인", action: dismissAction)
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .deleteImageConfirmation: Text("레시피의 대표 사진을 삭제할까요?")
        case .hasUnsavedChanges: Text("이 화면에서 나가면, 변경된 내용이 버려집니다.")
        case .incompleteDraft(let message): Text(message)
        case .userChanged: Text("기존과 다른 사용자로 로그인됐어요. 레시피 편집을 종료할게요.")
        case .sessionExpired: Text("로그아웃 상태로 전환됐어요. 레시피 편집을 종료할게요.")
        case .error(_, let message): Text(message)
        }
    }
}
