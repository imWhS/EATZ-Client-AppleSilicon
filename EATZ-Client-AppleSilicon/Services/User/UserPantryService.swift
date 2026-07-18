//
//  UserPantryService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/26.
//

import Foundation
import Alamofire

final class UserPantryService {
    static let shared = UserPantryService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/users/me/pantry"
    
    private init() {}
    
    func addAllRecipeRequirements(
        recipeId: Int64,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        let request = AddAllRequirementsRequest(recipeId: recipeId)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/add-all-recipe-requirements",
            method: .post,
            parameters: request,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success:
                    // 성공했지만, 응답 데이터는 무시하고 성공했다는 신호(.success(()))만 전달합니다.
                    completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func addAllChecklistRequirements(
        requirements: ChecklistRequirements,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/add-all-checklist-requirements",
            method: .post,
            parameters: requirements,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success:
                    // 성공했지만, 응답 데이터는 무시하고 성공했다는 신호(.success(()))만 전달합니다.
                    completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func addIngredients(
        ids: [Int64],
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        let addIngredients = AddIngredients(ingredientIds: ids)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/ingredients",
            method: .post,
            parameters: addIngredients,
            completion: { (result: Result<AddedIngredientResponse, NetworkError>) in
                switch result {
                case .success:
                    // 성공했지만, 응답 데이터는 무시하고 성공했다는 신호(.success(()))만 전달합니다.
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))}})
    }
    
    func removeIngredients(
        ids: [Int64],
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        let parameters = ["ingredientIds": ids]
        
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/ingredients",
            method: .delete,
            parameters: parameters,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func clearIngredients(
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/ingredients/all",
            method: .delete,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func clearKitchenwares(
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/kitchenwares/all",
            method: .delete,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func addKitchenwares(
        ids: [Int64],
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        let addKitchenwares = AddKitchenwares(kitchenwareIds: ids)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/kitchenwares",
            method: .post,
            parameters: addKitchenwares,
            completion: { (result: Result<AddedKitchenwareResponse, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))}})
    }
    
    func removeKitchenwares(
        ids: [Int64],
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        let paremeters = ["kitchenwareIds": ids]
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/kitchenwares",
            method: .delete,
            parameters: paremeters,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }})
    }
    
    func fetchKitchenwares(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<KitchenwareListPageResponse, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/kitchenwares",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func fetchIngredients(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<IngredientListPageResponse, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/ingredients",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func getKitchenwareCount(completion: @escaping (Result<CountResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/kitchenwares/count",
            method: .get,
            completion: completion)
    }
    
    func getIngredientCount(completion: @escaping (Result<CountResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/ingredients/count",
            method: .get,
            completion: completion)
    }
    
}
