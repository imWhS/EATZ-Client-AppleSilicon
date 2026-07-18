//
//  ThemeService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/24/25.
//

import Foundation
import Alamofire

final class ThemeService {
    static let shared = ThemeService()
    
    private lazy var networkClient = NetworkClient.shared
    
    private init() {}
    
    func fetchAllThemesWithTags(
        completion: @escaping (Result<[Theme], NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "/v0/themes/with-tags",
            method: .get,
            completion: completion
        )
    }
    
}
