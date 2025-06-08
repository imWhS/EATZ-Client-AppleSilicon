//
//  AuthService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/16/25.
//

import Foundation

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    private let networkClient = NetworkClient.shared
    
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        networkClient.authRequest(
            endpointUrl: "/login",
            parameters: parameters
        ) { result in
            switch result {
            case .success(let authTokens):
                completion(.success(authTokens.accessToken))
            case .failure(let networkError):
                completion(.failure(networkError))
            }
        }
    }
    
    func reissueTokens(completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        networkClient.authRequest(endpointUrl: "/reissue-token") { result in
            switch result {
            case .success(let authTokens):
                print("[AuthService.reissueTokens] 토큰 재발급 요청을 성공했어요! | \(authTokens.accessToken.suffix(8)) | \(authTokens.refreshToken.suffix(8))")
                completion(.success(authTokens.accessToken))
            case .failure(let networkError):
                print("[AuthService.reissueTokens] 토큰 재발급 요청을 실패했어요.")
                completion(.failure(networkError))
            }
        }
    }
    
    
    
}
