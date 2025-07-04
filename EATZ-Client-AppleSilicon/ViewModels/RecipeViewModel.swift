//
//  RecipeViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/19/25.
//

import SwiftUI

enum RecipeState: Equatable {
    case loading
    case loaded(RecipeResponse)
    case error(String)
}

enum RecipeIngredientListState {
    case idle
    case loading
    case loaded([RecipeIngredient])
    case error(String)
}

class RecipeViewModel: ObservableObject {
    
    private lazy var authManager = AuthManager.shared
    
    let recipeId: Int64
    
    private let recipeService = RecipeService()
    private let userService = UserService()
    
    @Published var state: RecipeState = .loading
    @Published var ingredientListState: RecipeIngredientListState = .idle
    @Published var isErrorAlertPresented = false
    @Published var errorAlertMessage: String?
    @Published var likedCount: Int64 = 0
    @Published var isLiked: Bool = false
    @Published var isUpdatingIngredient: [Int64: Bool] = [:]
    
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    func fetchRecipe() {
        state = .loading
        ingredientListState = .idle
        errorAlertMessage = nil
        
        recipeService.fetchRecipe(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipe):
                    self.isLiked = recipe.liked
                    self.likedCount = recipe.likedCount
                    self.state = .loaded(recipe)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.state = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        self.state = .error(errorResponse.message)
                    case .unknown:
                        self.state = .error("알 수 없는 이유로 레시피를 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func fetchIngredients() {
        ingredientListState = .loading
        recipeService.fetchRecipeIngredients(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let ingredients):
                    self.ingredientListState = .loaded(ingredients)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.ingredientListState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        self.ingredientListState = .error(errorResponse.message)
                    case .unknown:
                        self.ingredientListState = .error("알 수 없는 이유로 레시피 재료 목록을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func toggleLike() {        
        guard case .loaded(let recipe) = state else { return }

        authManager.performAfterLogIn {
            let beforeLike = recipe.liked
            let beforeLikedCount = recipe.likedCount
            
            self.isLiked.toggle()
            self.likedCount += self.isLiked ? 1 : -1
            
            self.recipeService.toggleRecipeLike(id: self.recipeId) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self.isLiked = response.isLiked
                        self.likedCount = response.count
                    case .failure:
                        self.isLiked = beforeLike
                        self.likedCount = beforeLikedCount
                    }
                }
            }
        }
    }
    
    func addIngredientToUser(ingredientId: Int64) {
        guard case .loaded(let ingredients) = ingredientListState else { return }
        if isUpdatingIngredient[ingredientId] == true { return }

        var newIngredients = ingredients
        guard let index = newIngredients.firstIndex(where: {$0.id == ingredientId }) else {
            return
        }
        
        isUpdatingIngredient[ingredientId] = true
        
        newIngredients[index].ownedByUser = true
        ingredientListState = .loaded(newIngredients)
        
        userService.addIngredient(ingredientIds: [ingredientId]) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isUpdatingIngredient[ingredientId] = false
                
                switch result {
                case .success:
                    break;
                case .failure:
                    var rollbackIngredients = newIngredients
                    if let index = rollbackIngredients.firstIndex(where: { $0.id == ingredientId }) {
                        rollbackIngredients[index].ownedByUser = false
                    }
                    self.ingredientListState = .loaded(rollbackIngredients)
                    self.errorAlertMessage = "재료를 추가하지 못했어요. 다시 시도해보시겠어요?"
                    self.isErrorAlertPresented = true
                }
            }
        }
    }
    
    func removeIngredientFromUser(ingredientId: Int64) {
        guard case .loaded(let ingredients) = ingredientListState else { return }
        if isUpdatingIngredient[ingredientId] == true { return }
        
        var newIngredients = ingredients
        guard let index = newIngredients.firstIndex(where: {$0.id == ingredientId }) else {
            return
        }
        
        isUpdatingIngredient[ingredientId] = true
        
        newIngredients[index].ownedByUser = false
        ingredientListState = .loaded(newIngredients)
        
        userService.removeIngredient(ingredientIds: [ingredientId]) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isUpdatingIngredient[ingredientId] = false
                
                switch result {
                case .success:
                    break;
                case .failure:
                    var rollbackIngredients = newIngredients
                    if let index = rollbackIngredients.firstIndex(where: { $0.id == ingredientId }) {
                        rollbackIngredients[index].ownedByUser = true
                    }
                    self.ingredientListState = .loaded(rollbackIngredients)
                    self.errorAlertMessage = "재료를 제거하지 못했어요. 다시 시도해보시겠어요?"
                    self.isErrorAlertPresented = true
                }
            }
        }
        
    }
    
    func refreshAllData() {
        fetchRecipe()
        fetchIngredients()
    }
    
}
