//
//  BlockService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/18/26.
//

import Foundation

final class ReportService {
    static let shared = ReportService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/reports"
    
    private init() {}
    
    func submit(
        _ request: ReportCreateRequest,
        completion: @escaping (Result<ReportCreateResponse, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: commonEndpointUrl,
            method: .post,
            parameters: request,
            completion: completion)
    }
    
    func fetchCategories(completion: @escaping (Result<[ReportCategory], NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/categories",
            method: .get,
            completion: completion)
    }
}
