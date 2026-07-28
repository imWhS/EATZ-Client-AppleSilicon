//
//  RecipeService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/17/25.
//

import Foundation
import Alamofire

final class RecipeService {
    static let shared = RecipeService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/recipes"
    
    private init() {}
    
    func register(
        _ recipe: RecipeCreateRequest,
        completion: @escaping (Result<RecipeCreateResponse, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: commonEndpointUrl,
            method: .post,
            parameters: recipe,
            completion: completion)
    }
    
    func update(
        for id: Int64,
        _ recipe: RecipeUpdateRequest,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .put,
            parameters: recipe,
            completion: completion)
    }
    
    func delete(
        for id: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .delete,
            completion: completion)
    }
    
    func uploadImage(imageData: Data, completion: @escaping (Result<UploadedImageResponse, NetworkError>) -> Void) {
        networkClient.uploadImage(
            endpointUrl: "\(commonEndpointUrl)/images",
            imageData: imageData,
            completion: { (result: Result<UploadedImageResponse, NetworkError>) in
                switch result {
                case .success(let response): completion(.success(response))
                case .failure(let error): completion(.failure(error))
                }
            })
    }
    
    func deleteImage(_ imageUrl: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/images",
            method: .delete,
            parameters: DeleteImageRequest(imageUrl: imageUrl),
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            })
    }
    
    func fetchRecipeUrl(id: Int64, completion: @escaping (Result<RecipeOutboundResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/urls/\(id)",
            method: .post,
            completion: completion)
    }
    
    func fetch(
        id: Int64,
        completion: @escaping (Result<Recipe, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .get,
            completion: completion)
    }
    
    func fetchEditable(
        id: Int64,
        completion: @escaping (Result<RecipeEditable, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/editable",
            method: .get,
            completion: completion)
    }
    
    func fetchEssential(
        id: Int64,
        completion: @escaping (Result<RecipeEssentialWithAuthor, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/essential",
            method: .get,
            completion: completion)
    }
    
    func search(
        keyword: String,
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let request = SearchRecipesRequest(
            keyword: keyword,
            page: page,
            size: size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/search",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func fetchExploreRecipes(
        searchCriteria: ExploreSearchCriteria,
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<ExploreRecipesResponse, NetworkError>) -> Void)
    {
        let request = ExploreRecipesRequest(searchCriteria: searchCriteria, page: page, size: size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/explore",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func fetchIngredients(
        id: Int64,
        completion: @escaping (Result<[RecipeIngredient], NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/ingredients",
            method: .get,
            completion: completion)
    }
    
    func fetchKitchenwares(
        id: Int64,
        completion: @escaping (Result<[RecipeKitchenware], NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(id)/kitchenwares",
            method: .get,
            completion: completion)
    }

    func fetchAllBasicsByAuthorId(
        id: Int64,
        page: Int,
        size: Int,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let request = FindRecipesByAuthorRequest(id, page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func fetchTodayCookableList(
        searchCriteria: CookableSearchCriteria,
        sort: CookableRecipeSort,
        size: Int,
        page: Int,
        completion: @escaping (Result<TodayCookableListResponse, NetworkError>) -> Void)
    {
        let fetchTodayCookableList = FetchTodayCookableList(
            keyword: searchCriteria.keyword,
            maxTotalTime: searchCriteria.maxTotalTime,
            servings: searchCriteria.servings,
            isCookableOnly: searchCriteria.isCookableOnly,
            sort: sort,
            page: page,
            size: size)
        
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/cookable",
            method: .get,
            parameters: fetchTodayCookableList,
            completion: completion)
    }
}

