//
//  RecipeViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/16/25.
//

import SwiftUI
import Alamofire
import Combine

/// RecipeView에서 필요한 데이터와 로직을 제공합니다.
@MainActor
class RecipeViewModel: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: RecipeViewState = .initialLoading
    
    @Published var detailState: RecipeDetailState?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RecipeAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: RecipeSheet?
    
    var authManager: AuthManager? {
        didSet {
            currentUser = authManager?.currentUser
        }
    }
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    /// 현재 보고 있는 레시피의 ID
    private let recipeId: Int64
    
    /// 현재 사용자
    private var currentUser: CurrentUser? {
        didSet {
            resetAndLoadAll()
        }
    }
    
    private var isPendingLike: Bool = false
    private var isPendingSave: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성 (Dependencies)
    
    lazy var requirementsViewModel: RecipeDetailRequirementsViewModel = {
        RecipeDetailRequirementsViewModel(
            recipeId: recipeId,
            onAlert: { alert in self.alert = alert }
        )
    }()
    
    // MARK: - 초기화 (Initialization)
    
    init(recipeId: Int64, auth: AuthProvider = AuthManager.shared) {
        self.recipeId = recipeId
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    /// - 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 기존 불러온 데이터를 화면에 표시 중인지, 사용자가 이전과 동일한지 확인한 후,
    ///   화면에 표시 중인 데이터가 없거나 사용자가 변경된 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if !validateContext() { return }
        resetAndLoadAll()
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadAll(completion: continuation.resume)
        }
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    private func loadAll(completion: @escaping () -> Void = {}) {
        clearPendingStates()
        loadRecipe(completion: completion)
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티의 상태를 초기화하고, 필요한 모든 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    private func resetAndLoadAll() {
        // 불러오기 상태 설정 필요 여부를 확인합니다. 앱 실행 후 뷰가 한 번도 보여진 적 없었던 경우에만 실행합니다.
        if viewState != .loaded { viewState = .initialLoading }

        detailState = nil
        loadAll()
    }

    /// 데이터를 불러올 필요성을 검증합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateContext() -> Bool {
        if case .loaded = viewState { return false }
        return true
    }
}

extension RecipeViewModel {
    func handleToggleLike() {
        guard case .loaded = viewState else { return }
        authManager?.performWhenLoggedIn {
            if self.isPendingLike { return }
            self.toggleLike()
        }
    }
    
    func handleToggleSave() {
        guard case .loaded = viewState else { return }
        authManager?.performWhenLoggedIn {
            if self.isPendingSave { return }
            self.toggleSave()
        }
    }
    
    func presentCalendar() {
        authManager?.performWhenLoggedIn {
            self.sheet = .plannerDatePicker(recipeId: self.recipeId)
        }
    }
    
    func handleShowRecipe() {
        authManager?.performWhenLoggedIn {
            self.showRecipe()
        }
    }
    
    private func showRecipe() {
        RecipeService.shared.fetchRecipeUrl(id: recipeId) { result in
            switch result {
            case .success(let response):
                let recipeUrl = response.recipeUrl
                print("DBG | \(#function) recipe url: \(recipeUrl)")
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func toggleLike() {
        guard var detailState = detailState else { return }
        
        isPendingLike = true
        
        let beforeLiked = detailState.isLiked
        let beforeLikedCount = detailState.likedCount
        detailState.isLiked.toggle()
        detailState.likedCount += detailState.isLiked ? 1 : -1
        self.detailState = detailState
        
        let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    detailState.isLiked = response.liked
                    detailState.likedCount = response.count
                case .failure(let error):
                    detailState.isLiked = beforeLiked
                    detailState.likedCount = beforeLikedCount
                    self.alert = .toggleLikeFailed(message: error.userMessage)
                }
                self.detailState = detailState
                self.isPendingLike = false
            }
        }
        
        if detailState.isLiked {
            RecipeLikeService.shared.likeRecipe(for: recipeId, completion: completionHandler) }
        else {
            RecipeLikeService.shared.unlikeRecipe(for: recipeId, completion: completionHandler) }
    }
    
    private func toggleSave() {
        guard var detailState = detailState else { return }
        
        isPendingSave = true
        
        let beforeSaved = detailState.isSaved
        detailState.isSaved.toggle()
        self.detailState = detailState
        
        let completionHandler: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                detailState.isSaved = beforeSaved
                self.alert = .toggleSaveFailed(message: networkError.userMessage)
            }
            self.detailState = detailState
            self.isPendingSave = false
        }
        
        if detailState.isSaved { UserService.shared.saveRecipe(for: recipeId, completion: completionHandler) }
        else { UserService.shared.unsaveRecipe(for: recipeId, completion: completionHandler) }
    }
    
    private func clearPendingStates() {
        isPendingSave = false
        isPendingLike = false
    }
    
    private func loadRecipe(completion: @escaping () -> Void = {}) {
        RecipeService.shared.fetch(id: recipeId) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipe):
                    let detailState = RecipeDetailState(recipe: recipe)
                    self.viewState = .loaded
                    self.detailState = detailState
                case .failure(let networkError):
                    self.viewState = .error(networkError.userMessage)
                }
                
                completion()
            }
        }
    }
}

/// 서버로부터 받은 `Recipe` 원본과 `RecipeView`에 의해 변경되어질 수 있는 사용자 별 상호 작용 상태를 함께 관리하는 모델입니다.
/// 또한, `RecipeView`가 원본을 가공하지 않고, 바로 UI에 쓸 수 있는 formatting된 데이터를 함께 제공합니다.
struct RecipeDetailState {
    // 핵심 데이터
    let recipe: Recipe
    
    // 인터랙션 관련 상태들
    var isLiked: Bool
    var isSaved: Bool
    
    var likedCount: Int
    var commentCount: Int
    var ratingCount: Int
    
    var commentCountLabel: String {
        if commentCount > 0 { return "\(commentCount)" }
        else { return "첫 댓글 등록" }
    }
    
    var ratingCountLabel: String {
        if ratingCount > 0 { return "\(ratingCount)" }
        else { return "첫 평가 등록" }
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.isLiked = recipe.liked
        self.isSaved = recipe.saved
        self.likedCount = recipe.likedCount
        self.commentCount = recipe.commentCount
        self.ratingCount = recipe.ratingIndicatorSummary?.count ?? 0
    }
}

enum RecipeViewState: Equatable {
    case initialLoading
    case loaded
    case error(String)
}
