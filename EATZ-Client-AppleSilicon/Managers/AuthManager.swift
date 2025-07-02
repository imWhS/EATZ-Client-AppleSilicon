//
//  AuthManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/16/25.
//

import Foundation
import SwiftUI

/// AuthView를 띄울 때 메시지를 함께 전달하기 위해 사용합니다.
enum AuthContext: Identifiable {
//    case logIn(onDismiss: (() -> Void)? = nil)
//    case authRequiredAction(onDismiss: (() -> Void)? = nil)
//    case sessionExpired(onDismiss: (() -> Void)? = nil)
    case logIn(onDismiss: ((Bool) -> Void)? = nil)
    case authRequiredAction(onDismiss: ((Bool) -> Void)? = nil)
    case sessionExpired(onDismiss: ((Bool) -> Void)? = nil)

    var id: String {
        switch self {
        case .logIn:
            return "logIn"
        case .authRequiredAction:
            return "authRequiredAction"
        case .sessionExpired:
            return "sessionExpired"
        }
    }
    
    // Equatable 프로토콜을 수동으로 준수합니다. 클로저는 비교할 수 없으므로, case의 종류만 비교합니다.
    static func == (lhs: AuthContext, rhs: AuthContext) -> Bool {
        switch (lhs, rhs) {
        case (.logIn, .logIn),
             (.authRequiredAction, .authRequiredAction),
             (.sessionExpired, .sessionExpired):
            return true
        default:
            return false
        }
    }

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
    
    /// 연관 값으로 전달된 onDismiss 클로저를 쉽게 꺼내쓰기 위한 편의 프로퍼티
//    var onDismiss: (() -> Void)? {
//        switch self {
//        case .logIn(let onDismiss), .authRequiredAction(let onDismiss), .sessionExpired(let onDismiss):
//            return onDismiss
//        }
//    }
    var onDismiss: ((Bool) -> Void)? {
        switch self {
        case .logIn(let onDismiss), .authRequiredAction(let onDismiss), .sessionExpired(let onDismiss):
            return onDismiss
        }
    }
}

/**
 앱 전역에서 사용자 인증 상태를 관리합니다.
 */
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private static let accessTokenKey = "accessToken"
    
    /// 실제 로그인·토큰 재발급 요청 등 인증 관련 API 호출은 AuthService에 위임합니다.
    private lazy var authService = AuthService.shared
    
    /// 현재 로그인 된 사용자 정보 요청 등 사용자 관련 API 호출은 UserService에 위임합니다.
    private lazy var userService = UserService.shared
    
    /// 현재 로그인(인증) 상태입니다.
    @Published var isLoggedIn: Bool = false
    
    /// 현재 로그인된 사용자 정보입니다.
    @Published var currentUser: CurrentUser? = nil
    
    @Published var isShowingAuthView: Bool = false
    
    @Published var isRequiredAuth: AuthContext? = nil
    
    private var accessToken: String? {
        didSet {
            DispatchQueue.main.async {
                self.isLoggedIn = (self.accessToken != nil)
                print("PRESENTDBG - isLoggedIn: \(self.isLoggedIn)")
            }
        }
    }
    
    
//    private var pendingAuthOnDismiss: (() -> Void)? = nil
    private var pendingAuthOnDismiss: ((Bool) -> Void)? = nil
    
    /// 로그인 후 실행해야 할 작업들을 일시적으로 보관합니다.
    private var pendingActions: [() -> Void] = []
    
    private init() {
        accessToken = KeychainService.load(key: Self.accessTokenKey)
        print("AUTHDBG [AuthManager] \(isLoggedIn ? "전역 로그인 상태로 초기화됐어요." : "전역 비로그인 상태로 초기화됐어요.")")
    }
    
    func requireAuthWithCompletion(_ context: AuthContext) {
        self.pendingAuthOnDismiss = context.onDismiss
        self.isRequiredAuth = context
    }
     
    func handleAuthDismiss() {
        self.isRequiredAuth = nil
        // 클로저를 실행할 때 현재 로그인 상태(self.isLoggedIn)를 전달합니다.
        self.pendingAuthOnDismiss?(self.isLoggedIn)
        self.pendingAuthOnDismiss = nil
    }
      
    func saveAccessToken(_ accessToken: String) -> Bool {
        let saved = KeychainService.save(accessToken, key: Self.accessTokenKey)
        if saved { self.accessToken = accessToken }
        return saved
    }
    
    /**
     인증이 필요한 액션을 실행하기 전에 로그인 여부를 먼저 확인합니다.
     로그인되어 있는 경우, 액션을 바로 실행하며 로그인되어 있지 않은 경우, 액션 실행을 잠시 보류한 후 로그인 뷰 modal을 표시합니다.
     */
    func performAfterLogIn(_ action: @escaping () -> Void) {
        if isLoggedIn {
            action()
        } else {
            print("[AuthManager.performAfterLogIn] 인증이 필요한 액션을 보류할게요.")
            pendingActions.append(action)
            isRequiredAuth = .authRequiredAction()
//            ModalManager.shared.sheet = .authMain(promptMessage: .authRequiredAction)
        }
    }
    
    
    
    /**
     잠시 보류했던 인증 필요 액션을 한 번에 순차적으로 실행합니다.
     */
    private func flushPendingActions() {
        let actions = pendingActions
        pendingActions.removeAll()
        if actions.count == 0 { return }

        print("DISMISSDBG - [AuthManager.flushPendingActions] 보류된 액션 \(actions.count)개를 실행할게요")
        actions.forEach { $0() }
    }
    
    /// 세션 만료 시 처리: 토큰 삭제, 로그아웃 상태, 로그인 뷰 sheet 표시
    func handleSessionExpired() {
        currentUser = nil
        clearTokens()
        isRequiredAuth = .sessionExpired()
//        ModalManager.shared.sheet = .authMain(promptMessage: .sessionExpired)
    }

    /// 앱에서 보관 중인 액세스 토큰을 초기화합니다.
    func clearTokens() {
        print("AUTHDBG 액세스 토큰 삭제할게요")
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
                        // 로그인 완료 시 처리: 현재 로그인 된 사용자 정보 조회 API를 호출하고, 보류된 모든 액션을 실행합니다.
                        self.fetchCurrentUser()
                        self.flushPendingActions()
                        
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
        if accessToken == nil { return }
        
        userService.getCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
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
