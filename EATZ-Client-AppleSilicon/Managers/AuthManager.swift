//
//  AuthManagerN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/21/25.
//

import Foundation
import Combine

protocol AuthProvider {
    var state: AuthState { get }
    var isLoggedIn: Bool { get }
    var currentUser: CurrentUser? { get }
    
    func performWhenLoggedIn(perform action: @escaping () -> Void)
    func requireAuthView()
    func validateSession(perform action: (() -> Void)?)
}

/// 전역 인증 상태를 나타냅니다.
enum AuthState: Equatable {
    // 앱 실행 직후, 액세스 토큰 유효성을 확인 중인 초기 상태
    case unknown
    
    // 게스트 상태. 비로그인 상태에 해당합니다.
    case unauthorized
    
    // 로그인 상태. 연관 값으로 로그인된 사용자 정보를 가집니다.
    case authenticated(user: CurrentUser)
}

/// 앱의 전역 인증 상태를 관리합니다.
/// 앱의 모든 곳에서 `authState` 를 구독해 사용자의 상태를 구분할 수 있습니다.
/// `authState`는  'Single source of truth' 원칙에 의해 반드시 AuthManager에 의해서만 변경될 수 있습니다.
/// 인증 관련한 UI 처리는 GlobalPresenter에게 맡깁니다.
final class AuthManager: ObservableObject, AuthProvider {
    // MARK: - 싱글톤 객체 프로퍼티
    
    static let shared = AuthManager()
    
    // MARK: - 공개 프로퍼티

    /// 사용자의 인증 상태를 제공합니다.
    @Published private(set) var state: AuthState = .unknown
    
    /// 현재 사용자의 로그인 여부를 제공합니다.
    var isLoggedIn: Bool {
        if case .authenticated = state { return true }
        return false
    }
    
    /// 회원(로그인된 사용자)인 경우, 사용자 정보를 제공합니다.
    /// 비로그인 사용자이거나, 아직 서버로부터 사용자 정보를 불러오지 못했다면 `nil`을 반환합니다.
    /// - `state`의 값이 `.authenticated`로 설정될 때마다 연관 값에 의해 동기화되는 연산 프로퍼티입니다. 이벤트 스트림을 중복으로 방출하지 않도록 하기 위해 `@Published`를 추가하지 않습니다.
    var currentUser: CurrentUser? {
        if case .authenticated(let user) = state { return user }
        return nil
    }
    
    // MARK: - 비공개 프로퍼티
    
    /// 전역 게스트 상태여서 로그인 상태가 필요한 액션 실행을 실패했을 때, 로그인 성공 후(전역 로그인 상태로 변경된 직후)에 다시 실행하기 위해 액션을 임시로 저장해두는 프로퍼티입니다.
    private var pendingActions: [() -> Void] = []
    
    /// 로그인 상태에서 액션 실행 중 세션 만료로 인해 실패했을 때, 재로그인 성공 후에 다시 실행하기 위해 액션을 임시로 저장해두는 프로퍼티입니다.
    private var retryActionsOnSessionExpired: [() -> Void] = []
    
    private var isHandlingSessionExpiration = false
    
    private let tokenManager = TokenManager.shared
    private lazy var authService = AuthService.shared
    private lazy var userService = UserService.shared
    
    private init() {
        DispatchQueue.main.async { [weak self] in
            self?.checkInitialState()
        }
    }
    
    init(initialState: AuthState) {
        self.state = initialState
    }
    
    /// 단순 로그인만 진행하기 위해 AuthView를 화면에 띄웁니다.
    /// 로그인 성공 직후 실행되어야 할 액션이 있는 경우, `runWhenAuthenticated`를 사용해야 합니다.
    func requireAuthView() {
        print("[AuthManager.requireAuthView] AuthView를 present 할게요.")
        guard case .unauthorized = state else {
            print(" - 게스트 상태여서 실행을 취소할게요.")
            return
        }
        AuthGlobalPresenter.shared.presentAuthView(context: .logIn)
    }
    
    /// 현재 사용자가 로그인 상태면 액션을 바로 실행하고, 게스트 상태면 AuthView를 띄워, 로그인 성공 직후에 액션을 실행합니다.
    func performWhenLoggedIn(perform action: @escaping () -> Void) {
        switch state {
        case .authenticated:
            print("[AuthManager.performWhenLoggedIn] 로그인이 필요한 액션을 바로 실행할게요.")
            action()
        case .unauthorized, .unknown:
            print("[AuthManager.performWhenLoggedIn] 로그인이 필요한 액션을 요청했어요. 액션은 잠시 보류시킨 후, 로그인을 위해 AuthView를 띄워볼게요.")
            pendingActions.append(action)
            AuthGlobalPresenter.shared.presentAuthView(context: .authRequiredAction)
        }
    }
    
    /// AuthInterceptor.retry()가 세션 만료 감지 후 재인증 실패 시 호출합니다.
    func sessionExpired(retryAction: @escaping () -> Void) {
        print("[AuthManager.sessionExpired] 세션 만료 처리를 시작할게요. 액션은 잠시 pending 후, AuthView를 띄울게요.")
        retryActionsOnSessionExpired.append(retryAction)
        
        if isHandlingSessionExpiration {
            print("[AuthManager.sessionExpired] - 이미 만료 처리 중인 작업이 있어서, 세션 만료 처리를 취소할게요.")
            return
        }
        
        // 여러 API 호출로 인해 세션 만료 감지가 동시에 발생했을 때 race condition을 예방합니다.
        isHandlingSessionExpiration = true

        AuthGlobalPresenter.shared.presentAuthView(context: .sessionExpired, onDismiss: {
            print("[AuthManager.sessionExpired] 사용자가 재로그인을 취소했어요.")
            self.logOut()
        })
    }
    
    /// 현재 사용자의 세션에서 로그아웃을 실행합니다. 모든 토큰을 삭제하며, 전역 게스트 상태로 설정합니다.
    func logOut() {
        print("[AuthManager.logOut] 로그아웃을 실행할게요.")
        tokenManager.clearAllTokens()
        state = .unauthorized
        pendingActions.removeAll()
        retryActionsOnSessionExpired.removeAll()
        isHandlingSessionExpiration = false
    }
    
    /// GlobalPresenter.presentAuthView()가 로그인 성공 시 호출합니다.
    /// 서버로부터 받은 액세스 토큰을 저장하고, 전역 로그인 상태로 설정합니다.
    func setStateAsAuthenticated(accessToken: String, user: CurrentUser) {
        let previousUser = self.currentUser
        tokenManager.saveAccessToken(accessToken)
        state = .authenticated(user: user)
        
        if let previousUser, previousUser.id != user.id {
            pendingActions.removeAll()
            retryActionsOnSessionExpired.removeAll()
            isHandlingSessionExpiration = false
            return
        }
        
        retryActionsOnSessionExpired.forEach { $0() }
        pendingActions.forEach { $0() }
        
        pendingActions.removeAll()
        retryActionsOnSessionExpired.removeAll()
        isHandlingSessionExpiration = false
    }
    
    /// 세션이 유효한지 검증합니다.
    /// 서버에 토큰 재발급 API를 호출하고, API로부터 받은 응답을 이용해 세션 유효성을 검증합니다.
    func validateSession(perform action: (() -> Void)? = nil) {
       // 로그인 상태가 아니면 더 이상 실행하지 않습니다.
       guard case .authenticated = state else {
           print("[AuthManager.validateSession] 전역 로그인 상태가 아니기 때문에 토큰 재발급 요청 실행을 취소할게요.")
           return
       }

       authService.reissueTokens { [weak self] result in
           DispatchQueue.main.async {
               switch result {
               case .success:
                   print("[AuthManager.validateSession] 토큰 재발급 요청을 성공했어요.")
                   // 토큰 재발급 API에서 성공 응답을 보낸 경우, 사용자 정보 조회 API도 추가 호출합니다.
                   self?.performSessionValidation(completion: action ?? {})
               case .failure:
                   // 토큰 재발급 API에서 실패 응답을 보낸 경우, 로그아웃 처리합니다.
                   print("[AuthManager.validateSession] 세션 유효성 검증을 실패했어요.")
                   self?.sessionExpired(retryAction: action ?? {})
               }
           }
       }
    }
    
    /// 현재 사용자의 정보를 서버로부터 불러옵니다.
    func fetchCurrentUser(completion: @escaping (Result<CurrentUser, Error>) -> Void) {
        guard tokenManager.loadAccessToken() != nil else {
            print("[AuthManager.fetchCurrentUser] 액세스 토큰이 존재하지 않아서 현재 사용자 정보 조회를 취소할게요.")
            completion(.failure(NetworkError.unknown("액세스 토큰이 존재하지 않아요.")))
            return
        }
        
        userService.getCurrentUser { result in
            switch result {
            case .success(let currentUser):
                print("[AuthManager.fetchCurrentUser] 현재 사용자 정보를 성공적으로 가져왔어요.")
                completion(.success(currentUser))
            case .failure(let error):
                print("[AuthManager.fetchCurrentUser] 현재 사용자 정보 조회를 실패했어요.")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 비공개 메서드
    
    /// 액세스 토큰 저장 여부를 확인하고, 서버를 통해 토큰 유효성을 검증해 앱 전역 인증 상태를 설정합니다.
    private func checkInitialState() {
        if tokenManager.loadAccessToken() != nil {
            print("[AuthManager.checkInitialState] Keychain에서 액세스 토큰을 발견했어요. 서버를 통해 사용자 정보 조회를 시도할게요.")
            performSessionValidation()
        } else {
            print("[AuthManager.checkInitialState] 게스트 상태로 설정할게요.")
            state = .unauthorized
        }
    }
    
    /// 현재 로그인 상태인 사용자의 세션이 서버에서 유효한지 확인합니다.
    func performSessionValidation(completion: (() -> Void)? = nil) {
        fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
                    print("[AuthManager.performSessionValidation] 세션 유효성 검증을 성공했어요. 로그인 상태로 설정할게요.")
                    self?.state = .authenticated(user: currentUser)
                    completion?()
                case .failure:
                    print("[AuthManager.performSessionValidation] 세션 유효성 검증을 실패했어요. 로그아웃 처리할게요.")
                    self?.logOut()
                }
            }
        }
    }
}

extension AuthManager {
    /// 인증(로그인) 상태의 프리뷰용 인스턴스입니다.
    static var previewAuthenticated: AuthManager {
        let user = CurrentUser(id: 1, username: "dev_preview", email: "devpreview@eatz.io", imageUrl: nil, role: .ROLE_MEMBER)
        return AuthManager(initialState: .authenticated(user: user))
    }
    
    /// 게스트 상태의 프리뷰용 인스턴스입니다.
    static var previewGuest: AuthManager {
        return AuthManager(initialState: .unauthorized)
    }
}
