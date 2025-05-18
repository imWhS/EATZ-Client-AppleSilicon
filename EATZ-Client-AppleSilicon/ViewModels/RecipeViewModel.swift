//
//  RecipeViewModel.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 3/31/25.
//

import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    
    @Published var recipe: RecipeResponse?
    
    @Published var ingredients: [RecipeIngredient]? = []
    
    @Published var isLoading = false
    
    @Published var isLoadingIngredients = false
    
    @Published var errorMessage: String?
    
    private let recipeService = RecipeServiceV0()
    
    func loadRecipe(id: Int64) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let recipe = try await recipeService.fetchRecipe(id: id)
            self.recipe = recipe
            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            print("레시피 조회 요청 실패: \(self.errorMessage ?? "")")
            isLoading = false
        }
    }
    
    func refreshIngredients(id: Int64) async {
        guard !isLoadingIngredients else { return }
        isLoadingIngredients = true
        do {
            let ingredients = try await recipeService.fetchIngredients(id: id)
            self.ingredients = ingredients
            isLoadingIngredients = false
        } catch {
            print("재료 목록 새로고침 실패: \(error)")
            isLoadingIngredients = false
        }
    }
    
}
