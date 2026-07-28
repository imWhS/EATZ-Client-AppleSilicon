//
//  LikeService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/3/25.
//

import Foundation

class RecipeLikeService {
    static let shared = RecipeLikeService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/recipes"
    
    private init() {}
    
    func likeRecipe(
        for id: Int64,
        completion: @escaping (Result<LikedRecipe, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/likeds",
            method: .post,
            completion: completion)
    }
    
    func unlikeRecipe(
        for id: Int64,
        completion: @escaping (Result<LikedRecipe, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/likeds",
            method: .delete,
            completion: completion)
    }
}
