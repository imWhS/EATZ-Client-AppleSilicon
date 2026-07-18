//
//  KitchenwareService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import Foundation
import Alamofire

final class KitchenwareService {
    static let shared = KitchenwareService()
    
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/kitchenwares"
    
    private init() {}
    
    func fetchAllKitchenwares(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<KitchenwareListPageResponse, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        
        networkClient.request(
            endpointUrl: commonEndpointUrl,
            method: .get,
            parameters: pageableRequest,
            completion: completion
        )
    }
    
    func search(
        name: String,
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<KitchenwareListPageResponse, NetworkError>) -> Void)
    {
        let kitchenwareSearch = KitchenwareSearch(name: name, pageableRequest: PageableRequest(page, size))
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/search",
            method: .get,
            parameters: kitchenwareSearch,
            completion: completion
        )
    }
    
    
}
