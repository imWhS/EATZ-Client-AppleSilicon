//
//  RecipeCommentService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/14/26.
//

import Foundation

final class RecipeCommentService {
    static let shared = RecipeCommentService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/recipes"
    
    private init() {}
    
    func register(
        for id: Int64,
        content: String,
        completion: @escaping (Result<Comment, NetworkError>) -> Void)
    {
        let request = RegisterCommentRequest(content: content)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/comments",
            method: .post,
            parameters: request,
            completion: completion)
    }
}

