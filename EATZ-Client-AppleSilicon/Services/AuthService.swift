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
    
    private let commonEndpointUrl: String = "/v0"
    
    private lazy var networkClient = NetworkClient.shared
    private let userService = UserService.shared
    private let tokenManager = TokenManager.shared
    
    func checkEmailAvailability(_ email: String, completion: @escaping (Result<EmailAvailabilityResponse, NetworkError>) -> Void) {
        let request = CheckEmailAvailabilityRequest(email: email)
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/auth/email-status",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func checkAccountStatusByEmail(_ email: String, completion: @escaping (Result<UserDetail, NetworkError>) -> Void) {
        let request = CheckAccountStatusByEmailRequest(email: email)
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/users/search",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func signUp(
        username: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let request = SignUpRequest(username: username, email: email, password: password)
        
        networkClient.requestPublicNoContent(
            endpointUrl: "\(commonEndpointUrl)/sign-up",
            method: .post,
            parameters: request,
            completion: completion
        )
    }
    
    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let resetPassword = ResetPassword(email: email)
        networkClient.requestPublicNoContent(
            endpointUrl: "\(commonEndpointUrl)/auth/reset-password/request",
            method: .post,
            parameters: resetPassword,
            completion: completion
        )
    }
    
    func submitNewPasswordForReset(
        authorizedToken: String,
        newPassword: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        let request = ConfirmPasswordResetRequest(authorizedToken: authorizedToken, newPassword: newPassword)
        networkClient.requestPublicNoContent(
            endpointUrl: "\(commonEndpointUrl)/auth/reset-password",
            method: .post,
            parameters: request,
            completion: completion
        )
    }
    
    func validateResetPasswordToken(
        emailVerificationToken: String,
        completion: @escaping (Result<ResetPasswordTokenValidationResponse, NetworkError>) -> Void
    ) {
        let request = ResetPasswordTokenValidationRequest(emailVerificationToken: emailVerificationToken)
        
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/auth/reset-password/authorize-token",
            method: .get,
            parameters: request,
            completion: completion
        )
    }
    
    func logIn(
        email: String,
        password: String,
        completion: @escaping (Result<(accessToken: String, user: CurrentUser), NetworkError>) -> Void
    ) {
        let request = LogInRequest(email: email, password: password)
        
        networkClient.authRequest(
            endpointUrl: "/login",
            disableApiBaseUrl: true,
            parameters: request
        ) { result in
            switch result {
            case .success(let authTokens):
                self.tokenManager.saveAccessToken(authTokens.accessToken)
                
                self.userService.getCurrentUser { response in
                    switch response {
                    case .success(let user):
                        // 토큰과 사용자 정보를 함께 반환합니다.
                        completion(.success((accessToken: authTokens.accessToken, user: user)))
                    case .failure(let error):
                        // 사용자 정보 조회 실패 시, 로그인 전체를 실패로 간주하고 롤백합니다.
                        self.tokenManager.clearAllTokens()
                        completion(.failure(error))
                    }
                }
                
            case .failure(let networkError):
                completion(.failure(networkError))
            }
        }
    }
    
    func reissueTokens(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkClient.authRequest(endpointUrl: "\(commonEndpointUrl)/reissue-token") { [weak self] result in
            switch result {
            case .success(let authTokens):
                // 성공 시 새로운 액세스 토큰을 저장합니다.
                self?.tokenManager.saveAccessToken(authTokens.accessToken)
                completion(.success(()))
            case .failure(let networkError):
                completion(.failure(networkError))
            }
        }
    }
    
    func checkVerificationStatus(email: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = CheckVerificationStatusRequest(email: email)
        networkClient.requestPublicNoContent(
            endpointUrl: "\(commonEndpointUrl)/sign-up/email-validation/status",
            method: .get,
            parameters: request,
            completion: completion
        )
    }
    
    func sendValidationCode(email: String, completion: @escaping (Result<SendVerificationCodeResponse, NetworkError>) -> Void) {
        let timeZoneId = TimeZone.current.identifier
        let request = SendValidationCodeRequest(email: email, timeZoneId: timeZoneId)
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/sign-up/email-validation",
            method: .post,
            parameters: request,
            completion: completion)
    }
    
    func verifyValidationCode(email: String, code: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = VerifyValidationCodeRequest(email: email, code: code)
        networkClient.requestPublicNoContent(endpointUrl: "\(commonEndpointUrl)/sign-up/email-validation/verify", method: .post, parameters: request, completion: completion)
    }
    
    func checkUsernameDuplication(username: String, completion: @escaping (Result<CheckUsernameDuplicationResponse, NetworkError>) -> Void) {
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let request = CheckUsernameDuplicationRequest(username: encodedUsername)
        networkClient.requestPublic(
            endpointUrl: "\(commonEndpointUrl)/users/check-username",
            method: .get,
            parameters: request,
            completion: completion)
    }
}
