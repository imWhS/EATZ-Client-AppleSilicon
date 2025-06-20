//
//  RecipeListViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/17/25.
//

import Foundation

class RecipeListViewModel: ObservableObject {
    
    private lazy var authManager = AuthManager.shared
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recipes: [RecipeListItem] = []
    @Published var hasNextPage = true
    
    private let recipeService = RecipeService()
    
    func fetchRecipeList(page: Int = 0, size: Int = 10) {
        isLoading = true
        errorMessage = nil
        print("로드로드로드중")
        
        recipeService.fetchRecipes(page: page, size: size) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.recipes = response.content
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.errorMessage = afError.localizedDescription
                    case .serverError(let errorResponse):
                        self.errorMessage = errorResponse.message
                    case .unknown:
                        self.errorMessage = "알 수 없는 이유로 레시피 목록을 받아오지 못했어요. 다시 시도해보시겠어요?"
                    }
                }
            }
        }
    }
    
    
}
