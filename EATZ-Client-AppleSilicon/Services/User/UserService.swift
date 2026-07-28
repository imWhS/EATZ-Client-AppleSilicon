//
//  UserService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/21/25.
//

import Foundation
import Alamofire

final class UserService {
    static let shared = UserService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/users"
    
    private init() {}
    
    func getCurrentUser(completion: @escaping (Result<CurrentUser, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me",
            method: .get,
            completion: completion)
    }
    
    func saveRecipe(
        for id: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        let saveRecipe = SaveRecipe(recipeId: id)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/saveds/recipes",
            method: .post,
            parameters: saveRecipe,
            completion: completion)
    }
    
    func unsaveRecipe(
        for id: Int64,
        completion: @escaping (Result<Empty, NetworkError>) -> Void)
    {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/saveds/recipes/\(id)",
            method: .delete,
            completion: completion)
    }
    
    func fetchSavedRecipes(
        page: Int = 0,
        size: Int = 2,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/saveds/recipes",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func fetchRatedRecipes(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/rateds/recipes",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func fetchLikedRecipes(
        page: Int = 0,
        size: Int = 2,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/likeds/recipes",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func fetchMyRecipes(
        page: Int = 0,
        size: Int = 10,
        completion: @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void)
    {
        let pageableRequest = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/recipes",
            method: .get,
            parameters: pageableRequest,
            completion: completion)
    }
    
    func getMyLikedRecipeCount(completion: @escaping (Result<CountResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/likeds/recipes/count",
            method: .get,
            completion: completion)
    }
    
    func getMyRatedRecipeCount(completion: @escaping (Result<CountResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/rateds/count",
            method: .get,
            completion: completion)
    }
    
    func getMyBio(completion: @escaping (Result<BioResponse, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/bio",
            method: .get,
            completion: completion)
    }
    
    func updateMyBio(bio: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = UpdateBioRequest(bio: bio)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/bio",
            method: .put,
            parameters: request,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            })
    }
    
    func updateMyImage(imageData: Data, completion: @escaping (Result<UploadedImageResponse, NetworkError>) -> Void) {
        networkClient.uploadImage(
            endpointUrl: "\(commonEndpointUrl)/me/image",
            method: .put,
            imageData: imageData,
            completion: { (result: Result<UploadedImageResponse, NetworkError>) in
                switch result {
                case .success(let response): completion(.success(response))
                case .failure(let error): completion(.failure(error))
                }
            })
    }
    
    func deleteMyImage(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/image",
            method: .delete,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }
    
    func updateMyUsername(username: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = UpdateUsernameRequest(username: username)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/username",
            method: .put,
            parameters: request,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: AuthManager.shared.performSessionValidation { completion(.success(())) }
                case .failure(let error): completion(.failure(error))
                }
            })
    }
    
    func deleteMyBio(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/bio",
            method: .delete,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }
    
    
    func fetchLikedIngredients(page: Int, size: Int, completion: @escaping (Result<IngredientListPageResponse, NetworkError>) -> Void) {
        let request = PageableRequest(page, size)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/me/likeds/ingredients",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func deactiveAccount(
        userId: Int64,
        existingPassword: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = DeactiveUserRequest(existingPassword: existingPassword)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/\(userId)/deactive",
            method: .delete,
            parameters: request,
            encodingType: .json,
            completion: { (result: Result<Empty, NetworkError>) in
                switch result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            })
    }
}
