//
//  RecipeService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/17/25.
//

import Foundation

final class RecipeService {
    
    private let networkClient = NetworkClient.shared
    
    func fetchRecipes(
        page: Int,
        size: Int,
        completion: @escaping (Result<RecipeListResponse, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "page": page,
            "size": size
        ]
        
        networkClient.request(
            endpointUrl: "/api/v0/recipes",
            method: .get,
            parameters: parameters,
            completion: completion
        )
    }
    
    func fetchRecipe(
        id: Int64,
        completion: @escaping (Result<RecipeResponse, NetworkError>) -> Void
    ) {
        networkClient.request(
            endpointUrl: "/api/v0/recipes/\(id)",
            method: .get,
            completion: completion
        )
    }
    
    func fetchRecipeIngredients(
        id: Int64,
        completion: @escaping (Result<[RecipeIngredient], NetworkError>) -> Void
    ) {
        networkClient.request(
            endpointUrl: "/api/v0/recipes/\(id)/ingredients",
            method: .get,
            completion: completion
        )
    }
    
    func toggleRecipeLike(
        id: Int64,
        completion: @escaping (Result<LikeResponse, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "entityId": id,
            "type": EntityType.recipe.rawValue
        ]
        
        networkClient.request(
            endpointUrl: "/api/v0/liked",
            method: .post,
            parameters: parameters,
            completion: completion)
    }
    
    func fetchRatingSummary(
        id: Int64,
        completion: @escaping (Result<RatingSummaryResponse, NetworkError>) -> Void
    ) {
        networkClient.request(
            endpointUrl: "/api/v0/recipes/\(id)/ratings/summary",
            method: .get,
            completion: completion)
    }
    
    func fetchRatings(
        id: Int64,
        completion: @escaping (Result<RatingListResponse, NetworkError>) -> Void
    ) {
        networkClient.request(
            endpointUrl: "/api/v0/recipes/\(id)/ratings",
            method: .get,
            completion: completion)
    }
    
    
    
}

