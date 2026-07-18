//
//  TagService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/24/25.
//

import Foundation
import Alamofire

final class TagService {
    static let shared = TagService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/tags"
    
    private init() {}
    
    func fetchAllThemesTags(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<ThemeTagItemListResponse, NetworkError>) -> Void) {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/themes",
            method: .get,
            parameters: pageableRequest,
            completion: completion
        )
    }
    
    func fetchTagBasic(id: Int64, completion: @escaping (Result<ExploreTagItem, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .get,
            completion: completion
        )
    }
    
    func search(
        name: String,
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<TagListItemResponse, NetworkError>) -> Void)
    {
        let tagSearch = TagSearch(name: name, pageableRequest: PageableRequest(page, size))
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/search",
            method: .get,
            parameters: tagSearch,
            completion: completion
        )
    }
}
