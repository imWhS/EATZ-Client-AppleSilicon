//
//  RecipeEditorViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/18/25.
//

import SwiftUI
import PhotosUI

/// 새로 등록하거나 수정하려는 레시피를 편집하려는 뷰 RecipeEditorView에서 필요한 데이터와 로직을 제공합니다.
///
/// 서버로부터 아래와 같은 데이터를 불러옵니다.
/// - 레시피를 수정하는 경우: 기존의 레시피 편집 데이터
class RecipeEditorViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰 상태
    ///
    /// - 레시피 초안은 사용자가 편집 가능한 레시피 데이터를 의미합니다.
    /// - 레시피 초안 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 뷰가 화면에 표시할 최상위 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var state: RecipeEditorState = .initialLoading
    
    /// 레시피 제출 상태
    @Published var submissionState: RecipeEditorSubmissionState = .idle
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: RecipeEditorSheet?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RecipeEditorAlert?
    
    /// 사용자가 현재 편집 중인 레시피 초안입니다.
    @Published var currentDraft = RecipeDraft()
    
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    @Published var isProcessingImage: Bool = false
    
    @Published var routingAction: RecipeEditorRoutingAction?
    
    /// 뷰의 Navigation Title에 표시할 문구입니다.
    /// - 초기 진입 모드에 따라 동적으로 설정됩니다.
    /// - Note: 한 번 설정된 모드는 뷰가 초기화된 이후에 변경되지 않기 때문에 상태 변경을 publishing하지 않습니다.
    var navigationTitleLabel: String { mode == .create ? "새 레시피" : "레시피 편집" }
    
    var timeSummaryLabel: String {
        let cookingTime = currentDraft.cookingTime ?? 0
        let prepTime = currentDraft.prepTime ?? 0
        let totalTime = cookingTime + prepTime
           
        if totalTime != 0,
           let totalTimeLabel = EatzDurationFormatter.seconds(from: totalTime) {
            return totalTimeLabel
        }
        
        return "소요 시간 추가"
    }
    
    var servingsLabel: String {
        if let servings = currentDraft.servings { return "\(servings)인" }
        else { return "제공량 추가" }
    }
    
    var creatorSummaryLabel: String {
        let name = currentDraft.creatorName ?? ""
        let url = currentDraft.creatorUrl ?? ""
        
        if !name.isEmpty { return name }
        else if !url.isEmpty { return url }
        else { return "출처 추가" }
    }
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    /// 레시피 제출 가능 여부를 나타냅니다.
    var isSubmittable: Bool {
        guard state == .content else { return false }
        
        return !currentDraft.hasInvalidImageUrl() &&
            !currentDraft.hasInvalidTitle() &&
            !currentDraft.hasInvalidUrl() &&
            !currentDraft.hasInvalidDescription() &&
            !currentDraft.hasInvalidCookingTime() &&
            !currentDraft.hasInvalidServings()
    }
    
    /// 현재 사용자 정보입니다.
    var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private var mode: RecipeEditorMode?
    
    /// 사용자의 기존 레시피 데이터입니다.
    /// - 수정 모드일 경우에만 값이 존재하며, 새 레시피를 작성하는 경우에는 `nil`이 됩니다.
    /// - 사용자가 뷰를 통해 기존 레시피 데이터에서 변경한 값이 있는지 판별하기 위해 사용합니다.
    private var recipeEditable: RecipeEditable? {
        didSet {
            currentDraft = RecipeDraft(from: recipeEditable)
        }
    }
    
    /// 현재 편집 중인 레시피 초안의 변경 사항 여부를 나타냅니다.
    private var hasDraftChanges: Bool {
        RecipeDraft(from: recipeEditable) != currentDraft
    }
    
    // MARK: - 의존성
    
    private let recipeService = RecipeService.shared
    
    /// 뷰 인스턴스 생성 시점에 필요한 메인 뷰 데이터를 불러옵니다.
    /// - 뷰 최초 진입 시에만 메인 뷰 데이터를 불러옵니다.
    /// - 뷰의 인스턴스가 갓 만들어져서, 메인 뷰 데이터를 최초로 불러와야 할 때 사용할 수 있습니다.
    func loadInitial(_ mode: RecipeEditorMode, _ authManager: AuthManager) {
        guard case .initialLoading = state else { return }
        
        self.mode = mode
        load(authManager)
    }
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에 주로 호출됩니다.
    func load(_ authManager: AuthManager?) {
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser(authManager) { return }

        state = .initialLoading
        switch mode {
        case .create: initializeEditable()
        case .update(let recipeId): loadEditable(for: recipeId)
        case .none: break
        }
    }
    
    /// 데이터를 불러올 필요성을 확인하기 위해 사용자를 검증하고, 검증 성공 시 현재 사용자 정보를 업데이트합니다.
    /// - 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에, 현재 전역 인증 상태(사용자 변경, 데이터 유무)에 따라 필요한 사전 작업을 수행합니다.
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화합니다.
    ///   단, 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화하고, 뷰를 dismiss 합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    func validateAndPrepareUser(_ authManager: AuthManager?) -> Bool {
        guard let authManager = authManager else { return false }
        
        if !authManager.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        // 로그인 사용자 변경 여부를 확인합니다. 직전에 뷰가 보여졌던 시점과 다른 사용자인 경우에만 실행합니다.
        if let user = currentUser,
           user.id != authManager.currentUser?.id {
            handleContextForNewUser()
            return false
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        self.state = .unauthorized
        self.clearAllContextData()
        alert = .sessionExpired(dismissAction: {
            self.routingAction = .dismiss
        })
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        self.state = .unauthorized
        self.clearAllContextData()
        alert = .userChanged(dismissAction: {
            self.routingAction = .dismiss
        })
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        currentDraft = RecipeDraft()
        recipeEditable = nil
        currentUser = nil
    }
}

extension RecipeEditorViewModel {
    func handleProfileImageSelection() {
        guard let item = selectedPhotoItem else { return }
        
        Task {
            do {
                let uiImage = try await PhotosPickerItemUtility.toUIImage(for: item)
                let resizedUiImage = uiImage.resized(maxDimension: 1024.0) ?? uiImage
                guard let jpegData = resizedUiImage.jpegData(compressionQuality: 0.8) else { return }
                DispatchQueue.main.async {
                    self.uploadImage(jpegData)
                }
            } catch {
                self.alert = .error(message: "사진을 정상적으로 불러오지 못했어요.")
            }
        }
    }
    
    /// `NavigationBar`의 `ToolbarItem` 중 취소('✕')  버튼을 탭했을 때의 동작을 처리합니다.
    /// - 기본적으로 뷰를 dismiss 합니다.
    /// - 변경 또는 추가 내용이 있으면, 관련 alert을 present합니다.
    func handleDismissAction() {
        let dismissAction: () -> Void = { self.routingAction = .dismiss }
        if hasDraftChanges { alert = .hasUnsavedChanges(confirmAction: dismissAction) }
        else { dismissAction() }
    }
    
    func handleSubmit() {
        guard case .content = state else { return }
        guard validateCurrentDraft() else { return }
        submit()
    }
    
    func handleDeleteImage() {
        alert = .deleteImageConfirmation(confirmAction: deleteImage)
    }
    
    private func deleteImage() {
        isProcessingImage = true
        recipeService.deleteImage(currentDraft.imageUrl) { [weak self] result in
            guard let self = self else { return }
            self.isProcessingImage = false
            switch result {
            case .success: self.currentDraft.imageUrl = ""
            case .failure(let networkError): self.alert = .error(title: "대표 사진 삭제 실패", message: networkError.userMessage)
            }
            self.selectedPhotoItem = nil
        }
    }
    
    private func uploadImage(_ data: Data) {
        isProcessingImage = true
        recipeService.uploadImage(imageData: data, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isProcessingImage = false
                switch result {
                case .success(let response): self.currentDraft.imageUrl = response.imageUrl
                case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
                }
            }
            self.selectedPhotoItem = nil
        })
    }
    
    private func initializeEditable(completion: (() -> Void)? = nil) {
        state = .content
        completion?()
    }
    
    /// 사용자의 기존 레시피 편집 데이터를 서버로부터 불러옵니다.
    private func loadEditable(for recipeId: Int64, completion: (() -> Void)? = nil) {
        recipeService.fetchEditable(id: recipeId) { [weak self] result in
            guard let self = self else { completion?(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEditable):
                    self.state = .content
                    self.recipeEditable = recipeEditable
                case .failure(let networkError): self.state = .error(message: networkError.userMessage)
                }
            }
            completion?()
        }
    }
    
    private func submit() {
        submissionState = .submitting
        
        // API 호출 후 실행될 공통 콜백 클로저를 정의합니다.
        let completionHandler: (Result<Any, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.submissionState = .idle
                switch result {
                case .success: self.routingAction = .submitCompleted
                case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
                }
            }
        }
        
        switch mode {
        case .create:
            let request = currentDraft.toCreateRequest()
            recipeService.register(request) { result in completionHandler(result.map { $0 as Any }) }
        case .update(let recipeId):
            let request = currentDraft.toUpdateRequest()
            recipeService.update(for: recipeId, request) { result in completionHandler(result.map { $0 as Any }) }
        case .none: break
        }
    }
    
    private func validateCurrentDraft() -> Bool {
        if currentDraft.hasInvalidImageUrl() {
            alert = .incompleteDraft(message: "레시피 대표 사진을 추가해주세요. 레시피 대표 사진은 필수 항목이에요.")
            return false
        }
        
        if currentDraft.hasInvalidTitle() {
            alert = .incompleteDraft(message: "레시피 제목을 입력해주세요. 레시피 제목은 필수 항목이에요.")
            return false
        }
        
        if currentDraft.hasInvalidUrl() {
            alert = .incompleteDraft(message: "레시피 URL 주소를 입력해주세요. 레시피 URL 주소는 필수 항목이에요.")
            return false
        }
        
        if currentDraft.hasInvalidDescription() {
            alert = .incompleteDraft(message: "레시피 설명을 입력해주세요. 레시피 설명은 필수 항목이에요.")
            return false
        }
        
        if currentDraft.hasInvalidCookingTime() {
            alert = .incompleteDraft(message: "소요 시간을 추가해주세요. 소요 시간은 필수 항목이며, 최소 1분 이상이어야 해요.")
            return false
        }
        if currentDraft.hasInvalidServings() {
            alert = .incompleteDraft(message: "제공량을 추가해주세요. 제공량은 필수 항목이며, 최소 1인 이상이어야 해요.")
            return false
        }
        return true
    }
}

/// 뷰 라우팅이 필요한 액션을 정의합니다.
enum RecipeEditorRoutingAction {
    case dismiss
    case submitCompleted
}

/// 레시피 제출(등록 또는 수정) 상태를 정의합니다.
enum RecipeEditorSubmissionState: Equatable {
    /// 대기 상태입니다. 기본 상태 값입니다.
    case idle
    
    /// 서버에 평가 제출을 위한 데이터를 전송 중인 상태입니다.
    case submitting
}

/// 뷰 초기화 및 초기화에 필요한 데이터의 불러오기 상태를 정의합니다.
enum RecipeEditorState: Equatable {
    /// 서버로부터 데이터를 불러오는 중인 상태입니다.
    case initialLoading
    
    /// 서버로부터 데이터를 가져와서, 해당 데이터를 이용해 화면에 레시피 편집 화면을 정상적으로 표시할 준비가 완료된 상태입니다.
    case content
    
    /// 권한이 없거나 세션이 만료되어, 화면에 레시피 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case unauthorized
    
    /// 서버로부터 데이터를 불러오는 과정에서 오류가 발생해 화면에 레시피 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case error(message: String)
}

enum RecipeEditorMode: Equatable {
    case create
    case update(_ recipeId: Int64)
}
