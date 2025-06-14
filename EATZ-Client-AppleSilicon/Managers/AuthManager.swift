//
//  AuthManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/16/25.
//

import Foundation
import SwiftUI

/// 로그인 sheet를 띄울 때 메시지를 함께 전달하기 위해 사용합니다.
enum AuthPresentMessageType: Identifiable {
    case logIn
    case authRequiredAction
    case sessionExpired

    var id: Int { hashValue }

    /// 로그인 시트에 보여줄 안내 메시지
    var message: String {
        switch self {
        case .logIn:
            return "이메일로 시작해볼까요?"
        case .authRequiredAction:
            return "로그인 후 계속 진행할 수 있어요."
        case .sessionExpired:
            return "인증이 만료됐어요. 다시 로그인해주세요."
        }
    }
}

/**
 앱 전역에서 사용자 인증 상태를 관리합니다.
 */
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    /// 실제 로그인·토큰 재발급 등 인증 관련 API 호출은 AuthService에 위임합니다.
    private lazy var authService = AuthService.shared
    private lazy var userService = UserService.shared
    
    private static let accessTokenKey = "accessToken"
    
    /// 현재 로그인(인증) 상태를 나타냅니다.
    @Published private(set) var isLoggedIn: Bool = false
    @Published var loginPrompt: AuthPresentMessageType? = nil
    @Published var currentUser: CurrentUser? = nil
    
    private var accessToken: String? {
        didSet {
            DispatchQueue.main.async {
                self.isLoggedIn = (self.accessToken != nil)
            }
        }
    }
    
    /// 로그인 후 실행해야 할 작업들을 일시적으로 보관합니다.
    private var pendingActions: [() -> Void] = []
    
    private init() {
        accessToken = KeychainService.load(key: Self.accessTokenKey)
        print("[AuthManager] \(isLoggedIn ? "전역 로그인 상태로 초기화됐어요." : "전역 비로그인 상태로 초기화됐어요.")")
        if accessToken == nil {
            clearTokens()
        }
    }
      
    func saveAccessToken(_ accessToken: String) -> Bool {
        let saved = KeychainService.save(accessToken, key: Self.accessTokenKey)
        if saved { self.accessToken = accessToken }
        return saved
    }
    
    /**
     인증이 필요한 액션을 실행하기 전에 로그인 여부를 먼저 확인합니다.
     로그인되어 있는 경우, 액션을 바로 실행하며 로그인되어 있지 않은 경우 액션 실행을 잠시 보류한 후, 로그인 뷰 modal을 표시합니다.
     */
    func performAfterLogIn(_ action: @escaping () -> Void) {
        if isLoggedIn {
            action()
        } else {
            print("[AuthManager.performAfterLogIn] 인증이 필요한 액션을 보류할게요.")
            pendingActions.append(action)
            ModalManager.shared.sheet = .authMain(promptMessage: .authRequiredAction)
//            loginPrompt = .authRequiredAction
        }
    }
    
    /// 로그인 완료 시 처리: 로그인 뷰 sheet 숨김, 현재 로그인 된 사용자 정보 API 호출
    func completeLogin() {
        print("[AuthManager.completeLogin]")
//        loginPrompt = nil
//        SheetManager.shared.sheet = nil
        fetchCurrentUser()
        flushPendingActions()
    }
    
    /**
     잠시 보류했던 인증 필요 액션을 한 번에 순차적으로 실행합니다.
     */
    private func flushPendingActions() {
        let actions = pendingActions
        pendingActions.removeAll()
        if actions.count == 0 { return }

        print("[AuthManager.flushPendingActions] 보류된 액션 \(actions.count)개를 실행할게요")
        actions.forEach { $0() }
    }
    
    /// 세션 만료 시 처리: 토큰 삭제, 로그아웃 상태, 로그인 뷰 sheet 표시
    func handleSessionExpired() {
        print("[AuthManager.handleSessionExpired]")
        currentUser = nil
        clearTokens()
//        print("[AuthManager] 화면에 로그인 뷰를 present 할게요!")
//        loginPrompt = .sessionExpired
        ModalManager.shared.sheet = .authMain(promptMessage: .sessionExpired)
    }

    /// 앱에서 보관 중인 액세스 토큰을 초기화합니다.
    func clearTokens() {
        print("[AuthManager.clearCredentials]")
        KeychainService.delete(key: Self.accessTokenKey)
        accessToken = nil
    }
    
    func logIn(
            email: String,
            password: String,
            completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        authService.logIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    // 액세스 토큰을 keychain에 저장 후 로그인 성공 처리합니다.
                    let saved = self.saveAccessToken(accessToken)
                    if saved {
                        // Keychain에 액세스 토큰 값이 저장됐다면, 전역 로그인 상태 처리 후 열려져 있을 수 있는 로그인 모달을 숨김 처리합니다.
                        self.completeLogin()
                        
                        print("[AuthManager.logIn] 전역 로그인 상태로 설정했어요.")
                        completion(.success(()))
                        return
                    } else {
                        // 키체인 저장 오류로 로그인 실패 처리합니다.
                        print("[AuthManager.logIn] 액세스 토큰을 keychain에 저장하지 못해 로그인 실패했어요.")
                        self.handleSessionExpired()
                        completion(.failure(.unknown("액세스 토큰을 keychain에 저장하지 못해 로그인 실패했어요.")))
                        return
                    }
                case .failure(let networkError):
                    // 네트워크 또는 서버 오류로 로그인 실패 처리합니다.
                    print("[AuthManager.logIn] 네트워크 또는 서버 오류로 인해 로그인 실패했어요.")
                    self.handleSessionExpired()
                    completion(.failure(networkError))
                }
            }
        }
    }
    
    func fetchCurrentUser() {
//        guard isLoggedIn else {
//            print("[AuthManager.fetchCurrentUser] 비로그인 상태여서 종료할게요.")
//            currentUser = nil
//            return
//        }
//        
        if accessToken == nil { return }
        print("[AuthManager.fetchCurrentUser] called! AuthManager.isLoggedIn: \(isLoggedIn)")
        
        userService.getCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
                    print("[AuthManager.fetchCurrentUser] 현재 로그인된 사용자 정보를 저장했어요.")
                    self?.currentUser = currentUser
                case .failure:
                    print("[AuthManager.fetchCurrentUser] 현재 로그인된 사용자 정보 저장을 실패했어요. 세션 만료 처리할게요.")
                    self?.handleSessionExpired()
                }
            }
        }
    }
    
    func reissueTokens(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        authService.reissueTokens { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    let saved = self.saveAccessToken(accessToken)
                    if saved {
                        completion(.success(()))
                    } else {
                        // 키체인 저장 오류로 토큰 재발급 실패 처리합니다.
                        print("[AuthManager.reissueTokens] 액세스 토큰을 keychain에 저장하지 못해 토큰 재발급 실패했어요. 로그아웃 처리할게요.")
                        self.handleSessionExpired()
                        completion(.failure(.unknown("액세스 토큰을 keychain에 저장하지 못해 토큰 재발급 실패했어요.")))
                    }
                case .failure(let networkError):
                    var errorMessage: String? = nil
                    switch networkError {
                    case .serverError(let errorResponse):
                        if errorResponse.errorCode == "TOKEN_REFRESH_EXPIRED"
                            || errorResponse.errorCode == "TOKEN_REFRESH_MISSING" {
                            print("[AuthManager.reissueTokens] 리프레시 토큰이 만료됐어요. 전역 로그아웃 처리할게요.")
                            self.handleSessionExpired()
                        } else {
                            print("[AuthManager.reissueTokens] 알 수 없는 서버 오류로 인해 토큰 재발급 실패했어요.")
                            errorMessage = "알 수 없는 서버 오류로 인해 인증이 만료됐어요. 다시 로그인해주세요."
                            self.handleSessionExpired()
                        }
                    default:
                        print("[AuthManager.reissueTokens] 네트워크 오류로 인해 토큰 재발급 실패했어요.")
                        errorMessage = "네트워크 오류로 인해 인증이 만료됐어요. 다시 로그인해주세요."
                        self.handleSessionExpired()
                    }
                    
                    if errorMessage != nil {
                        ErrorManager.shared.showError(message: "인증 오류예요. 다시 로그인해주세요.")
                    }
                    
                    completion(.failure(networkError))
                }
            }
        }
        
    }
    
}
