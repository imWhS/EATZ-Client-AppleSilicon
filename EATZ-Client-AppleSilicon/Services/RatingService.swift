//
//  RatingService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 4/16/26.
//

import Foundation
import Alamofire

final class RatingService {
    static let shared = RatingService()
    
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/ratings"
    
    private init() {}
    
    func delete(
        for id: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .delete,
            completion: completion)
    }
    
    func update(
        for id: Int64,
        score: Int,
        content: String,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        let updateRating = UpdateRating(score: score, content: content)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .put,
            parameters: updateRating,
            completion: completion)
    }
}
