//
//  TokenManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/21/25.
//

import Foundation

/// 앱의 인증 토큰(액세스 토큰 등)을 안전하게 키체인에 저장하고 관리합니다.
final class TokenManager {
    static let shared = TokenManager()
    
    /// 키체인에 데이터를 저장할 때 사용할 고유 키입니다.
    private let accessTokenKey = "com.eatz.accessToken"
    private let refreshTokenKey = "com.eatz.refreshToken"
    
    private init() {}
    
    /// 액세스 토큰을 키체인에 저장합니다.
    /// - Parameter token: 저장할 액세스 토큰 문자열
    func saveAccessToken(_ token: String) {
        let success = KeychainManager.save(token, key: accessTokenKey)
        if success {
            print("[TokenStorage.saveAccessToken] 액세스 토큰이 keychain에 성공적으로 저장됐어요.")
        } else {
            print("[TokenStorage.saveAccessToken] 액세스 토큰을 keychain에 저장 실패했어요.")
        }
    }
    
    /// 키체인에서 액세스 토큰을 불러옵니다. 없으면 `nil`을 반환합니다.
    func loadAccessToken() -> String? {
        if let token = KeychainManager.load(key: accessTokenKey) { return token }
        else {
           print("[TokenStorage.loadAccessToken] Keychain에 저장된 액세스 토큰이 없어요.")
           return nil
        }
    }
    
    /// 키체인에 저장된 모든 토큰을 삭제합니다.
    func clearAllTokens() {
        KeychainManager.delete(key: accessTokenKey)
        KeychainManager.delete(key: refreshTokenKey)
        print("[TokenStorage.clearAllTokens] Keychain에서 모든 토큰이 삭제됐어요.")
    }
}
    
