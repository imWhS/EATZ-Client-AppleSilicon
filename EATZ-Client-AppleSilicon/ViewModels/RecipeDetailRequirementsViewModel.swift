//
//  RecipeDetailRequirementsViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/18/25.
//

import SwiftUI

class RecipeDetailRequirementsViewModel: ObservableObject {
    @Published var viewState: RecipeDetailRequirementsViewState = .idle
    @Published var pendingKitchenwareIds: Set<Int64> = []
    @Published var pendingIngredientIds: Set<Int64> = []
    
    private let onAlert: ((RecipeAlert) -> Void)?
    private let recipeId: Int64
    
    /// 가장 최근에 데이터를 불러온 시점의 사용자 ID입니다.
    ///
    /// 데이터가 어떤 사용자를 기준으로 불러와졌는지 확인할 때 사용할 수 있습니다.
    private var lastLoadedUserId: Int64?
    
    private var auth: AuthProvider
    
    init(
        recipeId: Int64,
        onAlert: ((RecipeAlert) -> Void)? = nil,
        auth: AuthProvider = AuthManager.shared) {
        self.recipeId = recipeId
        self.onAlert = onAlert
        self.auth = auth
    }
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    ///
    /// 로그인 사용자가 변경되었거나 화면에 표시 중인 데이터가 없는 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if case .loaded = viewState, lastLoadedUserId ==  auth.currentUser?.id { return }

        resetAndLoadAll()
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    func resetAndLoadAll() {
        viewState = .loading
        lastLoadedUserId = auth.currentUser?.id
        resetPendingStates()
        loadRequirements()
    }
    
    func loadRequirements() {
        let group = DispatchGroup()
        var loadedIngredients: [RecipeIngredient]?
        var loadedKitchenwares: [RecipeKitchenware]?
        var error: NetworkError?
        
        group.enter()
        RecipeService.shared.fetchIngredients(id: recipeId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredients): loadedIngredients = ingredients
                case .failure(let networkError): error = networkError
                }
                group.leave()
            }
        }
        
        group.enter()
        RecipeService.shared.fetchKitchenwares(id: recipeId) { [weak self] result in
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
                self.viewState = .error(error.userMessage)
            } else if let ingredients = loadedIngredients, let kitchenwares = loadedKitchenwares {
                self.viewState = .loaded(
                    kitchenwares: kitchenwares,
                    ingredients: ingredients,
                    cookability: calculateCookability(
                        kitchenwares: kitchenwares,
                        ingredients: ingredients)
                )
            } else { self.viewState = .error("알 수 없는 이유로 레시피를 요리하기 위해 필요한 준비물 목록을 불러오지 못했어요.") }
        }
    }
    
    func calculateCookability(kitchenwares: [RecipeKitchenware], ingredients: [RecipeIngredient]) -> RecipeDetailRequirementsCookability {
        let missingKitchenwareCount = kitchenwares.filter { $0.ownedByUser == false }.count
        let missingIngredientCount = ingredients.filter { $0.ownedByUser == false }.count
        
        if missingIngredientCount > 0 || missingKitchenwareCount > 0 {
            return .uncookable(missingIngredientCount: missingIngredientCount, missingKitchenwareCount: missingKitchenwareCount)
        } else {
            return .cookable
        }
    }
    
    func handleAction(action: RecipeDetailRequirementsAction) {
        switch action {
        case .toggleKitchenwareAddition(let id): toggleKitchenwareAddition(of: id)
        case .toggleIngredientAddition(let id): toggleIngredientAddition(of: id)
        case .toggleLikeIngredient(let id): toggleLikeIngredient(of: id)
        }
    }
    
    func toggleLikeIngredient(of id: Int64) {
        guard case .loaded(let kitchenwares, let ingredients, _) = viewState else { return }
        guard let index = ingredients.firstIndex(where: { $0.id == id }) else { return }
        
        // 먼저 UI를 낙관적 업데이트 처리합니다.
        var newIngredients = ingredients
        newIngredients[index].likedByUser.toggle()
        let liked = newIngredients[index].likedByUser
        let cookability = calculateCookability(kitchenwares: kitchenwares, ingredients: newIngredients)
        self.viewState = .loaded(kitchenwares: kitchenwares, ingredients: newIngredients, cookability: cookability)
        
        let completionHandler: (Result<LikedIngredient, NetworkError>) -> Void = {  [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if case .failure(let networkError) = result {
                    var rollbackIngredients = newIngredients
                    if let index = rollbackIngredients.firstIndex(where: { $0.id == id }) {
                        rollbackIngredients[index].likedByUser.toggle()
                    }
                    let cookability = self.calculateCookability(kitchenwares: kitchenwares, ingredients: rollbackIngredients)
                    self.viewState = .loaded(kitchenwares: kitchenwares, ingredients: rollbackIngredients, cookability: cookability)
                    self.onAlert?(.likeIngredientFailed(message: networkError.userMessage))
                }
            }
        }
        
        if liked { IngredientLikeService.shared.likeIngredient(for: id, completion: completionHandler) }
        else { IngredientLikeService.shared.unlikeIngredient(for: id, completion: completionHandler) }
    }
    
    func toggleKitchenwareAddition(of id: Int64) {
        if pendingKitchenwareIds.contains(id) { return }
        guard case .loaded(let kitchenwares, let ingredients, _) = viewState else { return }
        guard let index = kitchenwares.firstIndex(where: { $0.id == id }) else { return }
        pendingKitchenwareIds.insert(id)
        
        // 먼저 UI를 낙관적 업데이트 처리합니다.
        var newKitchenwares = kitchenwares
        newKitchenwares[index].ownedByUser.toggle()
        let owned = newKitchenwares[index].ownedByUser
        let cookability = calculateCookability(kitchenwares: newKitchenwares, ingredients: ingredients)
        self.viewState = .loaded(kitchenwares: newKitchenwares, ingredients: ingredients, cookability: cookability)
        
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let networkError) = result {
                    var rollbackKitchenwares = newKitchenwares
                    if let index = rollbackKitchenwares.firstIndex(where: { $0.id == id }) {
                        rollbackKitchenwares[index].ownedByUser.toggle()
                    }
                    
                    let cookability = self.calculateCookability(kitchenwares: rollbackKitchenwares, ingredients: ingredients)
                    self.viewState = .loaded(kitchenwares: rollbackKitchenwares, ingredients: ingredients, cookability: cookability)
                    self.onAlert?(
                        owned ? .addKitchenwareFailed(message: networkError.userMessage) :
                                .removeKitchenwareFailed(message: networkError.userMessage))
                }
                self.pendingKitchenwareIds.remove(id)
            }
        }
        
        if owned { UserPantryService.shared.addKitchenwares(ids: [id], completion: completionHandler) }
        else { UserPantryService.shared.removeKitchenwares(ids: [id], completion: completionHandler) }
    }
    
    func toggleIngredientAddition(of id: Int64) {
        if pendingIngredientIds.contains(id) { return }
        guard case .loaded(let kitchenwares, let ingredients, _) = viewState else { return }
        guard let index = ingredients.firstIndex(where: { $0.id == id }) else { return }
        pendingIngredientIds.insert(id)
        
        // 먼저 UI를 낙관적 업데이트 처리합니다.
        var newIngredients = ingredients
        newIngredients[index].ownedByUser.toggle()
        let owned = newIngredients[index].ownedByUser
        let cookability = calculateCookability(kitchenwares: kitchenwares, ingredients: newIngredients)
        self.viewState = .loaded(kitchenwares: kitchenwares, ingredients: newIngredients, cookability: cookability)
        
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let networkError) = result {
                    var rollbackIngredients = newIngredients
                    if let index = rollbackIngredients.firstIndex(where: { $0.id == id }) {
                        rollbackIngredients[index].ownedByUser.toggle()
                    }
                    
                    let cookability = self.calculateCookability(kitchenwares: kitchenwares, ingredients: rollbackIngredients)
                    self.viewState = .loaded(kitchenwares: kitchenwares, ingredients: rollbackIngredients, cookability: cookability)
                    self.onAlert?(
                        owned ? .addIngredientFailed(message: networkError.userMessage) :
                                .removeIngredientFailed(message: networkError.userMessage))
                }
                self.pendingIngredientIds.remove(id)
            }
        }
        
        if owned { UserPantryService.shared.addIngredients(ids: [id], completion: completionHandler) }
        else { UserPantryService.shared.removeIngredients(ids: [id], completion: completionHandler) }
    }
    
    private func resetPendingStates() {
        pendingIngredientIds.removeAll()
        pendingKitchenwareIds.removeAll()
    }
}

enum RecipeDetailRequirementsAction {
    case toggleKitchenwareAddition(id: Int64)
    case toggleIngredientAddition(id: Int64)
    case toggleLikeIngredient(id: Int64)
}

enum RecipeDetailRequirementsCookability: Equatable {
    case cookable
    case uncookable(missingIngredientCount: Int, missingKitchenwareCount: Int)
}

enum RecipeDetailRequirementsViewState {
    case idle
    case loading
    case loaded(kitchenwares: [RecipeKitchenware], ingredients: [RecipeIngredient], cookability: RecipeDetailRequirementsCookability)
    case error(String)
}
