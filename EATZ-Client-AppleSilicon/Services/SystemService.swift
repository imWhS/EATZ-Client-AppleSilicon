//
//  SystemService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/6/26.
//

import Foundation

final class SystemService {
    static let shared = SystemService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/system"
    
    private init() {}
    
    func getClientVersion(completion: @escaping (Result<SystemClientVersionResponse, NetworkError>) -> Void) {
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/client/version/ios",
            method: .get,
            completion: completion)
    }
    
    func fetchLaunchNotice(completion: @escaping (Result<SystemClientLaunchNotice, NetworkError>) -> Void) {
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/client/notice/launch",
            method: .get,
            completion: completion)
    }
    
}
