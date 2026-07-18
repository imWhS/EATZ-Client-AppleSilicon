//
//  CommentService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 4/16/26.
//

import Foundation
import Alamofire

final class CommentService {
    static let shared = CommentService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/recipes"
    
    private init() {}
    
    func fetchAllPaged(
        id: Int64,
        size: Int,
        page: Int,
        completion: @escaping (Result<CommentsPaged, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/comments",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func update(
        id: Int64,
        recipeId: Int64,
        content: String,
        completion: @escaping (Result<Comment, NetworkError>) -> Void)
    {
        let updateComment = UpdateComment(content: content)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(recipeId)/comments/\(id)",
            method: .put,
            parameters: updateComment,
            completion: completion)
    }
    
    
    func delete(
        id: Int64,
        recipeId: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(recipeId)/comments/\(id)",
            method: .delete,
            completion: completion)
    }
}
