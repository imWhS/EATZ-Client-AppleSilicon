//
//  RatingEditorViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 1/30/26.
//

import SwiftUI
import Alamofire

/// 새로 등록하거나 수정하려는 평가를 편집하려는 뷰 RatingEditorView에서 필요한 데이터와 로직을 제공합니다.
///
/// 서버로부터 아래와 같은 데이터를 불러옵니다.
/// - 새 평가를 등록하거나, 기존의 평가를 수정할 대상 레시피의 요약 정보
/// - 평가를 수정하는 경우: 기존의 평가 편집 데이터
class RatingEditorViewModelN: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰 상태
    ///
    /// - 평가 초안은 사용자가 편집 가능한 평가 데이터를 의미합니다.
    /// - 평가 초안 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 뷰가 화면에 표시할 최상위 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var state: RatingEditorState = .initialLoading
    
    /// 평가 제출 상태
    @Published var submissionState: RatingEditorSubmissionState = .idle
    
    /// 평가 대상 레시피의 요약 정보
    @Published var recipeEssential: RecipeEssentialWithAuthor?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RatingEditorAlert?
    
    @Published var routingAction: RatingEditorRoutingAction?
    
    /// 사용자가 현재 편집 중인 평가입니다.
    @Published var currentDraft = RatingDraft()
    
    /// 뷰의 Navigation Title에 표시할 문구입니다.
    /// - 초기 진입 모드에 따라 동적으로 설정됩니다.
    /// - Note: 한 번 설정된 모드는 뷰가 초기화된 이후에 변경되지 않기 때문에 상태 변경을 publishing하지 않습니다.
    var navigationTitleLabel: String { mode == .create ? "새 평가" : "평가 편집" }
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    /// 평가 제출 가능 여부를 나타냅니다.
    var isSubmittable: Bool {
        guard state == .content else { return false }
        return currentDraft.hasInvalidScore()
    }
    
    /// 현재 사용자 정보입니다.
    var currentUser: CurrentUser?
    
    /// 사용자의 기존 평가 데이터입니다.
    /// - 수정 모드일 경우에만 존재하며, 새 평가를 작성하는 경우에는 `nil`이 됩니다.
    /// - 사용자가 뷰를 통해 기존 평가 데이터에서 변경한 값이 있는지 판별하기 위해 사용합니다.
    private var rating: Rating? {
        didSet {
            currentDraft = RatingDraft(from: rating)
        }
    }

    /// 현재 편집 중인 평가 초안의 변경 사항 여부를 나타냅니다.
    private var hasDraftChanges: Bool {
        RatingDraft(from: rating) != currentDraft
    }
    
    // MARK: - 기본 설정 프로퍼티
    
    private var recipeId: Int64?
    private var mode: RatingEditorMode?
    
    /// 뷰 인스턴스 생성 시점에 필요한 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 뷰 최초 진입 시에만 메인 뷰 데이터를 불러옵니다.
    /// - 뷰의 인스턴스가 갓 만들어져서, 메인 뷰 데이터를 최초로 불러와야 할 때 사용할 수 있습니다.
    func loadInitial(_ recipeId: Int64, _ mode: RatingEditorMode, _ authManager: AuthManager) {
        guard case .initialLoading = state else { return }
        
        self.recipeId = recipeId
        self.mode = mode
        load(authManager)
    }
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에 주로 호출됩니다.
    func load(_ authManager: AuthManager) {
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser(authManager) { return }
        
        // viewState가 .error일 때 등과 같이, 뷰에서 prepareDataIfNeeded를 다시 호출할 수도 있습니다.
        // 이때 사용자에게 데이터를 불러오고 있다는 피드백을 주기 위해 초기 데이터와 동일하더라도 viewState를 .loading으로 명시적으로 설정합니다.
        state = .initialLoading
        loadAllSequentially(authManager)
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
        state = .unauthorized
        clearAllContextData()
        alert = .sessionExpired(dismissAction: {
            self.routingAction = .dismiss
        })
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        state = .unauthorized
        clearAllContextData()
        alert = .userChanged(dismissAction: {
            self.routingAction = .dismiss
        })
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        currentDraft = RatingDraft()
        rating = nil
        currentUser = nil
    }
}

extension RatingEditorViewModelN {
    /// `NavigationBar`의 `ToolbarItem` 중 취소('✕')  버튼을 탭했을 때의 동작을 처리합니다.
    /// - 기본적으로 뷰를 dismiss 합니다.
    /// - 변경 또는 추가 내용이 있으면, 관련 alert을 present합니다.
    func handleDismissAction() {
        let dismissAction: () -> Void = { self.routingAction = .dismiss }
        if hasDraftChanges { alert = .hasUnsavedChanges(confirmAction: dismissAction) }
        else { dismissAction() }
    }
    
    func handleSubmit() {
        if submissionState == .submitting { return }
        guard currentDraft.score > 0 else {
            alert = .scoreNotSelected(confirmAction: { self.submissionState = .idle })
            return
        }
        
        submit()
    }
    
    private func loadAllSequentially(_ authManager: AuthManager, completion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        var errors: [(error: NetworkError, message: String)] = []
        let queue = DispatchQueue(label: "rating_editor_error_queue")
        
        let loadCompletionHandler: (((NetworkError, String)?) -> Void) = { error in
            if let error = error {
                queue.sync { errors.append(error) }
            }
            group.leave()
        }
        
        group.enter()
        loadRecipeEssential(completion: loadCompletionHandler)
        
        switch mode {
        case .create: initializeMyRating()
        case .update:
            group.enter()
            loadMyRating(completion: loadCompletionHandler)
        case .none: break
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.handleLoadInitialDataCompletion(errors: errors, completion: completion)
        }
    }
    
    /// 평가를 서버에 제출합니다.
    /// - `mode`가 `.update`인 경우 기존 평가 수정(update)을 요청하며, `.create`인 경우 평가를 생성한 후 대상 레시피에 등록(register)합니다.
    private func submit() {
        guard let recipeId = recipeId else { return }
        submissionState = .submitting
        
        // API 호출 후 실행될 공통 콜백 클로저를 정의합니다.
        let completionHandler: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
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
            RecipeRatingService.shared.register(
                for: recipeId,
                score: currentDraft.score,
                content: currentDraft.content,
                completion: completionHandler)
        case .update:
            RecipeRatingService.shared.updateMine(
                for: recipeId,
                score: currentDraft.score,
                content: currentDraft.content,
                completion: completionHandler)
        case .none: break
        }
    }
    
    /// 평가 대상인 레시피의 요약 정보 데이터를 서버로부터 불러옵니다.
    private func loadRecipeEssential(completion: (((NetworkError, String)?) -> Void)? = nil) {
        guard let recipeId = recipeId else { return }
        RecipeService.shared.fetchEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "평가하려는 레시피 정보를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    /// 사용자의 기존 평가 데이터를 서버로부터 불러옵니다.
    private func loadMyRating(completion: (((NetworkError, String)?) -> Void)? = nil) {
        guard let recipeId = recipeId else { return }
        RecipeRatingService.shared.fetchMine(for: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let rating):
                    self.rating = rating
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "회원님의 평가 정보를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func handleLoadInitialDataCompletion(errors: [(error: NetworkError, message: String)], completion: (() -> Void)? = nil) {
        defer { completion?() }
        
        if let error = errors.first(where: { $0.error.isServiceUnavailable }) {
            state = .error(message: error.message)
            return
        }
        
        if errors.count == 1, let error = errors.first {
            state = .error(message: error.1)
            return
        }
        
        if 1 < errors.count {
            state = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
            return
        }
        
        state = .content
    }
    
    private func initializeMyRating(completion: (() -> Void)? = nil) {
        state = .content
        completion?()
    }
}

/// 뷰 라우팅이 필요한 액션을 정의합니다.
enum RatingEditorRoutingAction {
    case dismiss
    case submitCompleted
}

/// 평가 제출(등록 또는 수정) 상태를 정의합니다.
enum RatingEditorSubmissionState: Equatable {
    /// 대기 상태입니다. 기본 상태 값입니다.
    case idle
    
    /// 서버에 평가 제출을 위한 데이터를 전송 중인 상태입니다.
    case submitting
}

/// 뷰 초기화 및 초기화에 필요한 데이터의 불러오기 상태를 정의합니다.
enum RatingEditorState: Equatable {
    /// 서버로부터 데이터를 불러오는 중인 상태입니다.
    case initialLoading
    
    /// 서버로부터 데이터를 가져와서, 해당 데이터를 이용해 화면에 평가 편집 화면을 정상적으로 표시할 준비가 완료된 상태입니다.
    case content
    
    /// 권한이 없거나 세션이 만료되어, 화면에 평가 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case unauthorized
    
    /// 서버로부터 데이터를 불러오는 과정에서 오류가 발생해 화면에 평가 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case error(message: String)
}

enum RatingEditorMode: Equatable {
    case create
    case update
}
