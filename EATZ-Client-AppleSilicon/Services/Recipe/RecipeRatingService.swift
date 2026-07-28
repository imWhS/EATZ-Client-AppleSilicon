//
//  RecipeRatingService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/14/26.
//

import Foundation
import Alamofire

final class RecipeRatingService {
    static let shared = RecipeRatingService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/recipes"
    
    private init() {}
    
    func register(
        for id: Int64,
        score: Int,
        content: String,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        let registerRating = RegisterRating(score: score, content: content)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings",
            method: .post,
            parameters: registerRating,
            completion: completion)
    }
    
    func deleteMine(
        for id: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings",
            method: .delete,
            completion: completion)
    }
    
    func updateMine(
        for id: Int64,
        score: Int,
        content: String,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        let request = UpdateRatingRequest(score: score, content: content)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings",
            method: .put,
            parameters: request,
            completion: completion)
    }
    
    func fetchMine(
        for id: Int64,
        completion: @escaping (Result<Rating?, NetworkError>) -> Void)
    {
        networkClient.requestOptional(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings/me",
            method: .get,
            completion: completion)
    }
    
    func fetchRatingIndicator(
        for id: Int64,
        completion: @escaping (Result<RatingIndicator, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings/indicator",
            method: .get,
            completion: completion)
    }
    
    func fetchAll(
        for id: Int64,
        page: Int,
        size: Int,
        completion: @escaping (Result<RatingsPaged, NetworkError>) -> Void)
    {
        let request = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ratings",
            method: .get,
            parameters: request,
            completion: completion)
    }
}
