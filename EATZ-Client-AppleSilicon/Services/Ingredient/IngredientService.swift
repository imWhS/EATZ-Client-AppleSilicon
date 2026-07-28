//
//  IngredientService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import Foundation
import Alamofire

final class IngredientService {
    static let shared = IngredientService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/ingredients"
    
    private init() {}
    
    func fetchIngredientDetail(
        id: Int64,
        completion: @escaping (Result<IngredientDetailResponse, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .get,
            completion: completion
        )
    }
    
    func fetchRoots(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<IngredientListPageResponse, NetworkError>) -> Void)
    {
        let request = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/roots",
            method: .get,
            parameters: request,
            completion: completion
        )
    }
    
    func search(
        name: String,
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<IngredientListPageResponse, NetworkError>) -> Void)
    {
        let request = SearchIngredientsRequest(keyword: name, pageableRequest: PageableRequest(page, size))
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/search",
            method: .get,
            parameters: request,
            completion: completion
        )
    }
}
