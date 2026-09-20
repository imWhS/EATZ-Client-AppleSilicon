//
//  AffiliateService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/20/26.
//

import Foundation
import Alamofire

final class AffiliateService {
    static let shared = AffiliateService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/affiliates"
    
    private init() {}
    
    func getAffiliateUrl(
        _ item: PurchaseItem? = nil,
        completion: @escaping (Result<AffiliateUrlResponse, NetworkError>) -> Void)
    {
        let request = AffiliateUrlRequest(type: item?.type, id: item?.id)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)",
            method: .get,
            parameters: request,
            completion: completion)
    }
}
