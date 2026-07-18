//
//  RecipeViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/8/26.
//

// C.C.

import SwiftUI
import Alamofire

/// RecipeView에서 필요한 데이터와 로직을 제공합니다.
@MainActor
class RecipeViewModelN: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 메인 뷰 데이터인 레시피 기본 정보 `Recipe` 상태
    ///
    /// - 레시피 기본 정보 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 뷰가 화면에 표시할 최상위 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var state: RecipeState = .initialLoading
    
    /// 레시피 요구 사항 관련 데이터 상태
    ///
    /// - 레시피 요구 사항 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 레시피 요구 사항 섹션에서 표시할 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var requirementsState: RecipeRequirementsState = .idle // TODO: .idle 필요성
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RecipeAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: RecipeSheet?
    
    /// 화면에 표시할 fullScreenCover
    /// - 아무 fullScreenCover도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var fullScreenCover: RecipeFullScreenCover?
    
    /// 차단하려는 사용자
    @Published var blockTargetUser: UserEssential?
    
    @Published var reportResource: ReportResource?
    
    @Published var routingAction: RecipeRoutingAction?
    
    var isCurrentUserAuthor: Bool {
        if case .content(let recipe) = state, recipe.author.id == currentUser?.id {
            return true
        }
        return false
    }
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    var currentUser: CurrentUser?
    
    private var isPendingLike: Bool = false
    private var isPendingSave: Bool = false
    
    private var pendingKitchenwareIds: Set<Int64> = []
    private var pendingIngredientIds: Set<Int64> = []
    
    /// 뷰 인스턴스 생성 시점에 필요한 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 뷰 최초 진입 시에만 메인 뷰 데이터를 불러옵니다.
    /// - 뷰의 인스턴스가 갓 만들어져서, 메인 뷰 데이터를 최초로 불러와야 할 때 사용할 수 있습니다.
    func loadInitial(for recipeId: Int64, _ currentUser: CurrentUser?) {
        // 메인 뷰 데이터 상태가 .initialLoading일 때만 동작합니다.
        guard case .initialLoading = state else { return }
    
        if self.currentUser == nil {
            self.currentUser = currentUser
        }
        
        load(for: recipeId)
    }
    
    /// 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 모든 뷰 상태 관련 프로퍼티를 `.initialLoading` 또는 `.idle`로 설정합니다.
    /// - 네트워크 오류 발생 등으로 인해 메인 뷰 데이터 상태가 `.error`일 떄, 메인 뷰 데이터 불러오기를 재시도 해야할 때 사용할 수 있습니다.
    func load(for recipeId: Int64) {
        state = .initialLoading
        requirementsState = .idle
        
        loadRecipe(for: recipeId)
    }
    
    /// 메인 뷰 데이터를 백그라운드로 불러옵니다.
    func loadQuietly(for recipeId: Int64) {
        loadRecipe(for: recipeId)
    }
    
    /// 기존 불러온 적 있는 모든 뷰 데이터를 새로 고칩니다.
    ///
    /// 이미 존재하는 뷰 데이터를 그대로 화면에 표시하고 있는 상태에서 최신 뷰 데이터로 덮어써야 하는 경우에 사용할 수 있습니다.
    func refresh(for recipeId: Int64) async {
        await withCheckedContinuation { continuation in
            loadRecipe(for: recipeId, completion: continuation.resume)
        }
        
        // 이미 요구 사항 섹션 관련 뷰 데이터를 불러온 적 있는 경우에만 해당 뷰 데이터를 업데이트합니다.
        switch requirementsState {
        case .content, .error: loadRequirementsIfNeeded(for: recipeId)
        case .idle, .loading: break
        }
    }
    
    func handleCurrentUserChanged(_ recipeId: Int64, _ previous: CurrentUser?, _ new: CurrentUser?) {
        if previous?.id != new?.id {
            currentUser = new
            Task { await refresh(for: recipeId) }
        }
    }
}

extension RecipeViewModelN {
    func showRecipe() {
        guard case .content(let recipe) = state else { return }
        RecipeService.shared.fetchRecipeUrl(id: recipe.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let recipeUrl = URL(string: response.recipeUrl) else { return }
                self.fullScreenCover = .recipeWebPageView(url: recipeUrl)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    func handleAddAllRequirementsToPantry() {
        guard case .content(_, _, let cookability) = requirementsState else { return }
        guard case .uncookable(let missingIngredientCount, let missingKitchenwareCount) = cookability else { return }
        alert = .confirmAddingAllRequirementsToPantry(
            ingredientsCount: missingIngredientCount,
            kitchenwaresCount: missingKitchenwareCount,
            confirmAction: {
                self.addAllRequirementsToPantry()
            })
    }
    
    private func addAllRequirementsToPantry() {
        guard case .content(let recipe) = state else { return }
        UserPantryService.shared.addAllRecipeRequirements(recipeId: recipe.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.alert = .addedAllRequirementsToPantry(completion: {
                self.loadRequirements(for: recipe.id)
            })
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    func presentPlannerDatePicker(for recipeId: Int64) {
        sheet = .plannerDatePicker(recipeId: recipeId)
    }
    
    func handleBlockAuthor() {
        guard case .content(let recipe) = state else { return }
        blockTargetUser = recipe.author.toUserEssential()
    }
    
    func handleReport() {
        guard case .content(let recipe) = state else { return }
        reportResource = ReportResource(id: recipe.id, authorId: recipe.author.id, authorUsername: recipe.author.username, type: .RECIPE, content: recipe.title)
    }
    
    func toggleLike(for recipeId: Int64) {
        guard !isPendingLike else { return }
        guard case .content(var recipe) = state else { return }
        
        isPendingLike = true
        
        let previousLiked = recipe.liked
        let previousLikedCount = recipe.likedCount
        
        // 뷰를 낙관적 업데이트 처리하기 위해, 먼저 레시피 좋아요의 기존 상태를 토글한 후, 토글된 상태를 반영한 좋아요 수를 설정합니다.
        recipe.liked.toggle()
        recipe.likedCount += recipe.liked ? 1 : -1
        
        // 뷰를 낙관적 업데이트 처리합니다.
        state = .content(recipe)
        
        // 서버 통신 결과 및 실패 시 롤백을 처리할 클로저를 미리 정의합니다.
        let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    recipe.liked = response.liked
                    recipe.likedCount = response.count
                case .failure(let error):
                    // 실패한 경우, 낙관적 업데이트 직전의 원본 상태로 되돌립니다.
                    recipe.liked = previousLiked
                    recipe.likedCount = previousLikedCount
                    self.alert = .toggleLikeFailed(message: error.userMessage)
                }
                self.state = .content(recipe)
                self.isPendingLike = false
            }
        }
        
        if recipe.liked { RecipeLikeService.shared.likeRecipe(for: recipeId, completion: completionHandler) }
        else { RecipeLikeService.shared.unlikeRecipe(for: recipeId, completion: completionHandler) }
    }
    
    func toggleSave(for recipeId: Int64) {
        guard !isPendingSave else { return }
        guard case .content(var recipe) = state else { return }
        
        isPendingSave = true
        
        let previousSaved = recipe.saved
        
        // 뷰를 낙관적 업데이트 처리하기 위해, 먼저 레시피 저장의 기존 상태를 토글합니다.
        recipe.saved.toggle()
        
        // 뷰를 낙관적 업데이트 처리합니다.
        state = .content(recipe)
        
        // 서버 통신 결과 및 실패 시 롤백을 처리할 클로저를 미리 정의합니다.
        let completionHandler: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 실패한 경우, 낙관적 업데이트 직전의 원본 상태로 되돌립니다.
                if case .failure(let networkError) = result {
                    recipe.saved = previousSaved
                    self.alert = .toggleSaveFailed(message: networkError.userMessage)
                }
                self.state = .content(recipe)
                self.isPendingSave = false
            }
        }
        
        if recipe.saved { UserService.shared.saveRecipe(for: recipeId, completion: completionHandler) }
        else { UserService.shared.unsaveRecipe(for: recipeId, completion: completionHandler) }
    }
    
    func handleUpdate(_ recipeId: Int64) {
        fullScreenCover = .recipeEditor(mode: .update(recipeId))
    }
    
    func handleDelete(_ recipeId: Int64) {
        alert = .confirmDelete(confirmAction: { self.delete(recipeId) })
    }
    
    func loadRequirementsIfNeeded(for recipeId: Int64) {
        guard case .idle = requirementsState else { return }
        loadRequirements(for: recipeId)
    }
    
    func loadRequirements(for recipeId: Int64) {
        let group = DispatchGroup()
        var loadedIngredients: [RecipeIngredient]?
        var loadedKitchenwares: [RecipeKitchenware]?
        var error: NetworkError?
        
        group.enter()
        RecipeService.shared.fetchIngredients(id: recipeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredients): loadedIngredients = ingredients
                case .failure(let networkError): error = networkError
                }
                group.leave()
            }
        }
        
        group.enter()
        RecipeService.shared.fetchKitchenwares(id: recipeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let kitchenwares): loadedKitchenwares = kitchenwares
                case .failure(let networkError): error = networkError
                }
                group.leave()
            }
        }
        
        // 서버를 통해 모든 요청을 실행했을 때
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if let error = error {
                self.requirementsState = .error(error.userMessage)
            } else if let ingredients = loadedIngredients, let kitchenwares = loadedKitchenwares {
                self.requirementsState = .content(
                    kitchenwares,
                    ingredients,
                    calculateCookability(kitchenwares, ingredients)
                )
            } else { self.requirementsState = .error("알 수 없는 이유로 레시피를 요리하기 위해 필요한 준비물 목록을 불러오지 못했어요.") }
        }
    }
    
    func handleRequirementsAction(action: RecipeDetailRequirementsAction) {
        switch action {
        case .toggleKitchenwareAddition(let id): toggleKitchenwareAddition(of: id)
        case .toggleIngredientAddition(let id): toggleIngredientAddition(of: id)
        case .toggleLikeIngredient(let id): toggleLikeIngredient(of: id)
        }
    }
    
    func toggleLikeIngredient(of id: Int64) {
        guard case .content(let kitchenwares, let ingredients, _) = requirementsState else { return }
        guard let index = ingredients.firstIndex(where: { $0.id == id }) else { return }
        
        // 먼저 UI를 낙관적 업데이트 처리합니다.
        var newIngredients = ingredients
        newIngredients[index].likedByUser.toggle()
        let liked = newIngredients[index].likedByUser
        let cookability = calculateCookability(kitchenwares, newIngredients)
        requirementsState = .content(kitchenwares, newIngredients, cookability)
        
        let completionHandler: (Result<LikedIngredient, NetworkError>) -> Void = {  [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if case .failure(let networkError) = result {
                    var rollbackIngredients = newIngredients
                    if let index = rollbackIngredients.firstIndex(where: { $0.id == id }) {
                        rollbackIngredients[index].likedByUser.toggle()
                    }
                    let cookability = self.calculateCookability(kitchenwares, rollbackIngredients)
                    self.requirementsState = .content(kitchenwares, rollbackIngredients, cookability)
                    self.alert = .likeIngredientFailed(message: networkError.userMessage)
                }
            }
        }
        
        if liked { IngredientLikeService.shared.likeIngredient(for: id, completion: completionHandler) }
        else { IngredientLikeService.shared.unlikeIngredient(for: id, completion: completionHandler) }
    }
    
    func toggleKitchenwareAddition(of id: Int64) {
        if pendingKitchenwareIds.contains(id) { return }
        guard case .content(var kitchenwares, let ingredients, _) = requirementsState else { return }
        guard let index = kitchenwares.firstIndex(where: { $0.id == id }) else { return }
        
        pendingKitchenwareIds.insert(id)
        
        // 뷰를 낙관적 업데이트 처리하기 위해, 먼저 도구의 기존 상태를 토글합니다.
        kitchenwares[index].ownedByUser.toggle()
        
        // 낙관적 업데이트를 실제로 반영해야 할 목표 상태를 보관해 둡니다.
        let expectedOwned = kitchenwares[index].ownedByUser
        
        // 뷰를 낙관적 업데이트 처리합니다.
        // 도구의 토글된 새 상태와 해당 재료의 새 상태로 다시 계산한 cookability를 뷰에 반영합니다.
        setRequirementsStateAsContent(kitchenwares, ingredients)
        
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let networkError) = result {
                    // 낙관적 업데이트 처리할 시점부터, 서버 응답을 받은 시점 사이에 requirementsState 상태 변화가 있을 수 있기 때문에,
                    // 원본 상태로 되돌릴 때 사용할 requirementsState의 현재 상태를 새로 캡처합니다.
                    guard case .content(var currentKitchenwares, let currentIngredients, _) = self.requirementsState
                    else { return }
                    
                    if let index = currentKitchenwares.firstIndex(where: { $0.id == id }) {
                        currentKitchenwares[index].ownedByUser.toggle()
                    }
                    
                    // 낙관적 업데이트 직전의 원본 상태로 되돌립니다.
                    // 도구가 토글되기 전 원본 상태와 해당 도구의 원본 상태로 다시 계산한 cookability를 뷰에 반영합니다.
                    self.setRequirementsStateAsContent(currentKitchenwares, currentIngredients)
                    
                    // 실패 관련 alert를 present 합니다.
                    if expectedOwned { self.alert = .addKitchenwareFailed(message: networkError.userMessage) }
                    else { self.alert = .removeKitchenwareFailed(message: networkError.userMessage) }
                }
                self.pendingKitchenwareIds.remove(id)
            }
        }
        
        if expectedOwned { UserPantryService.shared.addKitchenwares(ids: [id], completion: completionHandler) }
        else { UserPantryService.shared.removeKitchenwares(ids: [id], completion: completionHandler) }
    }
    
    func toggleIngredientAddition(of id: Int64) {
        if pendingIngredientIds.contains(id) { return }
        guard case .content(let kitchenwares, var ingredients, _) = requirementsState else { return }
        guard let index = ingredients.firstIndex(where: { $0.id == id }) else { return }
        
        pendingIngredientIds.insert(id)
        
        // 뷰를 낙관적 업데이트 처리하기 위해, 먼저 재료의 기존 상태를 토글합니다.
        ingredients[index].ownedByUser.toggle()
        
        // 낙관적 업데이트를 실제로 반영해야 할 목표 상태를 보관해 둡니다.
        let expectedOwned = ingredients[index].ownedByUser
        
        // 뷰를 낙관적 업데이트 처리합니다.
        // 재료의 토글된 새 상태와 해당 재료의 새 상태로 다시 계산한 cookability를 뷰에 반영합니다.
        setRequirementsStateAsContent(kitchenwares, ingredients)
        
        // 서버 통신 결과 및 실패 시 롤백을 처리할 클로저를 미리 정의합니다.
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 실패한 경우, 낙관적 업데이트 직전의 원본 상태로 되돌려야 합니다.
                if case .failure(let networkError) = result {
                    // 낙관적 업데이트 처리할 시점부터, 서버 응답을 받은 시점 사이에 requirementsState 상태 변화가 있을 수 있기 때문에,
                    // 원본 상태로 되돌릴 때 사용할 requirementsState의 현재 상태를 새로 캡처합니다.
                    guard case .content(let currentKitchenwares, var currentIngredients, _) = self.requirementsState
                    else { return }
                    
                    if let index = currentIngredients.firstIndex(where: { $0.id == id }) {
                        currentIngredients[index].ownedByUser.toggle()
                    }
                    
                    // 낙관적 업데이트 직전의 원본 상태로 되돌립니다.
                    // 재료가 토글되기 전 원본 상태와 해당 재료의 원본 상태로 다시 계산한 cookability를 뷰에 반영합니다.
                    self.setRequirementsStateAsContent(currentKitchenwares, currentIngredients)
                    
                    // 실패 관련 alert를 present 합니다.
                    if expectedOwned { self.alert = .addIngredientFailed(message: networkError.userMessage) }
                    else { self.alert = .removeIngredientFailed(message: networkError.userMessage) }
                }
                self.pendingIngredientIds.remove(id)
            }
        }
        
        if expectedOwned { UserPantryService.shared.addIngredients(ids: [id], completion: completionHandler) }
        else { UserPantryService.shared.removeIngredients(ids: [id], completion: completionHandler) }
    }
    
    private func delete(_ recipeId: Int64) {
        RecipeService.shared.delete(for: recipeId) { result in
            switch result {
            case .success: self.alert = .deleted(dismissAction: { self.routingAction = .dismiss })
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func resetPendingStates() {
        pendingIngredientIds.removeAll()
        pendingKitchenwareIds.removeAll()
    }
    
    private func loadRecipe(for recipeId: Int64, completion: @escaping () -> Void = {}) {
        RecipeService.shared.fetch(id: recipeId) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipe): self.state = .content(recipe)
                case .failure(let networkError): self.state = .error(networkError.userMessage)
                }
                
                completion()
            }
        }
    }
    
    private func clearPendingStates() {
        isPendingSave = false
        isPendingLike = false
    }
    
    private func calculateCookability(_ kitchenwares: [RecipeKitchenware], _ ingredients: [RecipeIngredient]) -> RecipeDetailRequirementsCookability {
        let missingKitchenwareCount = kitchenwares.filter { !$0.ownedByUser }.count
        let missingIngredientCount = ingredients.filter { !$0.ownedByUser }.count
        
        if missingIngredientCount > 0 || missingKitchenwareCount > 0 {
            return .uncookable(missingIngredientCount: missingIngredientCount, missingKitchenwareCount: missingKitchenwareCount)
        } else {
            return .cookable
        }
    }
    
    private func setRequirementsStateAsContent(_ kitchenwares: [RecipeKitchenware], _ ingredients: [RecipeIngredient]) {
        let cookability = calculateCookability(kitchenwares, ingredients)
        requirementsState = .content(kitchenwares, ingredients, cookability)
    }
}

enum RecipeState {
    case initialLoading
    case content(_ recipe: Recipe)
    case error(_ message: String)
}

enum RecipeRequirementsState {
    case idle
    case loading
    case content(
        _ recipeKitchenware: [RecipeKitchenware],
        _ recipeIngredient: [RecipeIngredient],
        _ cookability: RecipeDetailRequirementsCookability
    )
    case error(_ message: String)
}

/// 뷰 라우팅이 필요한 액션을 정의합니다.
enum RecipeRoutingAction {
    case dismiss
}
