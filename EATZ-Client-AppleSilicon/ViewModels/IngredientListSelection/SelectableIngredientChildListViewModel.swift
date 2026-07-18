//
//  SelectableIngredientChildListViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import SwiftUI

@MainActor
class SelectableIngredientChildListViewModel: ObservableObject {
    @Published var childIngredients: [Ingredient] = []
    @Published var isLoading = false
    
    private let ingredientService = IngredientService.shared
    private let parentId: Int64
    
    init(parentId: Int64) {
        self.parentId = parentId
    }
    
    func loadChildIngredients() {
        isLoading = true
        ingredientService.fetchIngredientDetail(id: parentId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success(let response) = result {
                    guard let children = response.children else {
                        self.childIngredients = []
                        return
                    }
                    self.childIngredients = children.map { child in
                        return Ingredient(from: child)
                    }
                }
            }
        }
    }
}
