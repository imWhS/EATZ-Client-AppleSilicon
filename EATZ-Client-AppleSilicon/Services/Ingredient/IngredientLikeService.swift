//
//  LikeService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/3/25.
//

import Foundation

class IngredientLikeService {
    static let shared = IngredientLikeService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/ingredients"
    
    private init() {}
    
    func likeIngredient(    
        for id: Int64,
        completion: @escaping (Result<LikedIngredient, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/likeds",
            method: .post,
            completion: completion)
    }
    
    func unlikeIngredient(
        for id: Int64,
        completion: @escaping (Result<LikedIngredient, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/likeds",
            method: .delete,
            completion: completion)
    }
    
}
