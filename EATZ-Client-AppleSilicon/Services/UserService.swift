//
//  UserService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/21/25.
//

import Foundation
import Alamofire

final class UserService {
    
    static let shared = UserService()
    
    private let networkClient = NetworkClient.shared
    
    func getCurrentUser(completion: @escaping (Result<CurrentUser, NetworkError>) -> Void
    ) {
        networkClient.request(
            endpointUrl: "/api/v0/users/me",
            method: .get,
            completion: completion
        )
    }
    
    func addIngredient(
        ingredientIds: [Int64],
        completion: @escaping (Result<AddedIngredientResponse, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "ingredientIds": ingredientIds
        ]
        
        networkClient.request(
            endpointUrl: "/api/v0/users/ingredients",
            method: .post,
            parameters: parameters,
            completion: completion
        )
    }
    
    func removeIngredient(
        ingredientIds: [Int64],
        completion: @escaping (Result<Empty, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "ingredientIds": ingredientIds
        ]
        
        networkClient.request(
            endpointUrl: "/api/v0/users/ingredients",
            method: .delete,
            parameters: parameters,
            completion: completion
        )
        
    }
    
}
