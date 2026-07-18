//
//  BlockService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/18/26.
//

import Foundation

final class UserBlockService {
    static let shared = UserBlockService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/users/me/blockeds"
    
    private init() {}
    
    func block(
        for id: Int64,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        networkClient.requestNoContent(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .post,
            completion: completion)
    }
    
    func unblock(
        for id: Int64,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        networkClient.requestNoContent(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .delete,
            completion: completion)
    }
    
    func getBlocklist(
        page: Int,
        size: Int,
        completion: @escaping (Result<BlocklistResponse, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
}
