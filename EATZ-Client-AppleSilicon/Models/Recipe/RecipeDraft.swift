//
//  RecipeDraft.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import Foundation

struct RecipeDraft: Equatable {
    var imageUrl: String = ""
    var title: String = ""
    var url: String = ""
    var description: String = ""
    
    var cookingTime: Int?
    var prepTime: Int?
    
    var servings: Int?
    
    var ingredients: [IngredientEssential] = []
    var kitchenwares: [KitchenwareEssential] = []
    var tagNames: [String] = []
    
    var creatorName: String?
    var creatorUrl: String?
    
    var isCommentEnabled: Bool = true
    
    init() {}
    
    init(from recipeEditable: RecipeEditable? = nil) {
        if let recipe = recipeEditable {
            imageUrl = recipe.imageUrl
            title = recipe.title
            url = recipe.url
            description = recipe.description
            cookingTime = recipe.cookingTime
            prepTime = recipe.prepTime
            servings = recipe.servings
            ingredients = recipe.ingredients
            kitchenwares = recipe.kitchenwares
            tagNames = recipe.tagNames
            isCommentEnabled = recipe.isCommentEnabled
            creatorName = recipe.creatorName
            creatorUrl = recipe.creatorUrl
        } else {
            imageUrl = ""
            title = ""
            url = ""
            description = ""
            cookingTime = nil
            prepTime = nil
            servings = nil
            ingredients = []
            kitchenwares = []
            tagNames = []
            creatorName = nil
            creatorUrl = nil
        }
    }
    
    /// 레시피 생성(등록)을 요청할 때 쓸 수 있는 `RecipeCreateRequest` 타입 인스턴스로 변환합니다.
    ///
    /// `cookingTime`과 `servings`는 생성할 때 필수 값이어서 강제 unwrapping합니다.
    /// 그래서 이 메서드를 실행하기 전에 반드시 해당 값들이 `nil`이 아님을 검증해야 합니다.
    func toCreateRequest() -> RecipeCreateRequest {
        return RecipeCreateRequest(
            imageUrl: imageUrl,
            title: title,
            url: url,
            description: description,
            cookingTime: cookingTime!,
            prepTime: prepTime,
            servings: servings!,
            kitchenwareIds: kitchenwares.map { $0.id },
            ingredientIds: ingredients.map { $0.id },
            tagNames: tagNames,
            creatorName: creatorName,
            creatorUrl: creatorUrl,
            isCommentEnabled: isCommentEnabled
        )
    }
    
    /// 레시피 업데이트(수정)을 요청할 때 쓸 수 있는 `RecipeCreateRequest` 타입 인스턴스로 변환합니다.
    ///
    /// `cookingTime`과 `servings`는 업데이트 때 필수 값이어서 강제 unwrapping합니다.
    /// 그래서 이 메서드를 실행하기 전에 반드시 해당 값들이 `nil`이 아님을 검증해야 합니다.
    func toUpdateRequest() -> RecipeUpdateRequest {
        return RecipeUpdateRequest(
            imageUrl: imageUrl,
            title: title,
            url: url,
            description: description,
            cookingTime: cookingTime!,
            prepTime: prepTime,
            servings: servings!,
            kitchenwareIds: kitchenwares.map { $0.id },
            ingredientIds: ingredients.map { $0.id },
            tagNames: tagNames,
            creatorName: creatorName,
            creatorUrl: creatorUrl,
            isCommentEnabled: isCommentEnabled
        )
    }
    
    func hasInvalidImageUrl() -> Bool {
        imageUrl.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func hasInvalidTitle() -> Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func hasInvalidUrl() -> Bool {
        url.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func hasInvalidDescription() -> Bool {
        description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func hasInvalidCookingTime() -> Bool {
        guard let cookingTime = cookingTime else { return true }
        return cookingTime < 1
    }
    
    func hasInvalidServings() -> Bool {
        guard let servings = servings else { return true }
        return servings < 1
    }
}
