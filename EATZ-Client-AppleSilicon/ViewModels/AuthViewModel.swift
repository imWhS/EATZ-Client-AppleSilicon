//
//  AuthViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI
import Combine

/**
 `AuthViewModel`은 AuthView 및 하위 뷰에서 필요한 UI 상태, 사용자 입력 데이터, 로직 등을 관리합니다.
 뷰에서는 이 뷰 모델의 상태를 구독해 UI를 업데이트 할 수 있습니다.
 
 이 뷰 모델은 아래와 같은 역할을 합니다.
 - 사용자가 입력한 이메일 주소를 저장합니다.
 - 이메일 주소가 올바른지 검증합니다.
 */
@MainActor
class AuthViewModel: ObservableObject {
    enum AuthNavigationPath: Hashable {
        case logIn
        case signUpEmailVerification
        case signUpSetPassword
        case signUpCreateUsername
    }
    
    // MARK: - 공개 프로퍼티
    
    @Published var isLoading: Bool = false
    @Published var isLoadingForResetPassword: Bool = false
    @Published var email: String = ""
    @Published var alert: AuthAlert?
    @Published var isValidatedAccount: Bool = false
    @Published var shouldPushToLogIn: Bool = false
    @Published var shouldPushToSignUp: Bool = false
    
    @Published var dailyLimitsForCreationValidationCode: Int?
    @Published var remainingAttemptsForCreationValidationCode: Int?
    @Published var validationCode: String = ""
    
    @Published var password: String = ""
    @Published var username: String = ""
    
    @Published var navigationPath: [AuthNavigationPath] = []
    
    @Published var isAlreadyVerified: Bool = false
    
    @Published var lastValidationCode: String = ""
    
    /// 로그인 성공 시 호출해야 할 클로저입니다.
    let onLogInSuccess: (String, CurrentUser) -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    private let userService = UserService.shared
    private let authService = AuthService.shared
    
    var isPasswordValid: Bool {
        return password.count >= 8 && password.count <= 64
    }

    var isUsernameValid: Bool {
        let regexPattern = "^[a-z0-9_.]{4,20}$"
        return username.range(of: regexPattern, options: .regularExpression) != nil
    }

    init(onLogInSuccess: @escaping (String, CurrentUser) -> Void) {
        self.onLogInSuccess = onLogInSuccess
        
        $navigationPath
            .sink { [weak self] path in
                // AuthView로 되돌아 온 경우
                if path.isEmpty {
                    self?.clearPrivacyData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 공개 메서드
    
    /// 이메일 주소의 유효성을 검사합니다.
    func validateEmail() {
        isLoading = true
        defer { isLoading = false }
        
        if email.isEmpty {
            alert = .emailInvalid(message: "이메일 주소를 입력하세요.")
            return
        }
        
        if !email.isValidEmail {
            alert = .emailInvalid(message: "올바른 형식의 이메일 주소인지 확인해보세요.")
            return
        }
        
        checkUserStatusbyEmail()
    }
    
    func checkUserStatusbyEmail() {
        authService.checkEmailAvailability(email) { result in
            switch result {
            case .success(let response):
                switch response.availability {
                case .available: self.prepareForSignUp()
                case .inUse: self.prepareForLogIn()
                case .inCoolDown:
                    self.isLoading = false
                    self.alert = .error(message: response.message)
                }
            case .failure(let networkError):
                self.isLoading = false
                self.alert = .error(message: networkError.userMessage)
            }
        }
//        authService.checkAccountStatusByEmail(email) { result in
//            switch result {
//            case .success(let user):
//                if user.deletedAt != nil {
//                    self.prepareForSignUp()
//                } else {
//                    self.isLoading = false
//                    self.navigationPath.append(.logIn)
//                }
//            case .failure(let networkError):
//                if networkError.statusCode == 404 {
//                    self.prepareForSignUp()
//                    return
//                }
//                
//                self.isLoading = false
//                self.alert = .error(message: networkError.userMessage)
//            }
//        }
    }
    
    func prepareForLogIn() {
        isLoading = false
        navigationPath.append(.logIn)
    }
    
    func prepareForSignUp() {
        isLoading = true
        authService.checkVerificationStatus(email: email) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.isLoading = false
                self.alert = .alreadyVerifiedEmail
                self.navigationPath.append(.signUpSetPassword)
            case .failure(let networkError):
                guard networkError.statusCode == 404 else {
                    self.isLoading = false
                    self.alert = .error(message: networkError.userMessage)
                    return
                }
                self.sendValidationCode { result in
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        self.dailyLimitsForCreationValidationCode = response.dailyIssuableLimits
                        self.remainingAttemptsForCreationValidationCode = response.remainingIssuableAttempts
                        self.navigationPath.append(.signUpEmailVerification)
                    case .failure(let networkError):
                        if networkError.statusCode == 429 { // 횟수 초과 오류인 경우
                            self.alert = .exceededSendVerificationCodeLimit(
                                email: self.email,
                                dailyLimits: self.dailyLimitsForCreationValidationCode ?? 3
                            )
                        } else {
                            self.alert = .error(message: networkError.userMessage)
                        }
                    }
                }
            }
        }
    }
    
    func logIn() {
        isLoading = true
        authService.logIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let (accessToken, user)):
                    self.onLogInSuccess(accessToken, user)
                    
                case .failure(let networkError):
                    self.alert = .error(message: networkError.userMessage)
                }
            }
        }
    }
    
    func resetPassword() {
        isLoadingForResetPassword = true
        authService.resetPassword(email: email) { [weak self] result in
            self?.isLoadingForResetPassword = false
            guard let self = self else { return }
            switch result {
            case .success: self.alert = .sentResetPasswordMail
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    func sendValidationCode(completion: @escaping (Result<SendVerificationCodeResponse, NetworkError>) -> Void = { _ in }) {
        authService.sendValidationCode(email: email) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.dailyLimitsForCreationValidationCode = response.dailyIssuableLimits
                    self.remainingAttemptsForCreationValidationCode = response.remainingIssuableAttempts
                    completion(.success(response))
                case .failure(let networkError):
                    completion(.failure(networkError))
                }
            }
        }
    }
    
    func resendValidationCode() {
        isLoading = true
        authService.sendValidationCode(email: email) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.dailyLimitsForCreationValidationCode = response.dailyIssuableLimits
                    self.remainingAttemptsForCreationValidationCode = response.remainingIssuableAttempts
                    self.alert = .resentVerifyCode
                case .failure(let networkError):
                    if networkError.statusCode == 429 { // 횟수 초과 오류인 경우
                        self.alert = .exceededSendVerificationCodeLimit(
                            email: self.email,
                            dailyLimits: self.dailyLimitsForCreationValidationCode ?? 3
                        )
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
            }
        }
    }
    
    func validateValidationCode() {
        if !validationCode.allSatisfy({ $0.isNumber }) {
            validationCode = lastValidationCode
            alert = .verificationCodeInvalid
        } else if validationCode.count > 6 {
            validationCode = lastValidationCode
        } else {
            lastValidationCode = validationCode
            if validationCode.count == 6 {
                verifyValidationCode()
            }
        }
    }
    
    func verifyValidationCode() {
        if isAlreadyVerified {
            navigationPath.append(.signUpSetPassword)
            return
        }
        
        isLoading = true
        authService.verifyValidationCode(email: email, code: validationCode) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAlreadyVerified = true
                    self.navigationPath.append(.signUpSetPassword)
                case .failure(let networkError):
                    self.isAlreadyVerified = false
                    if networkError.errorCode == "INVALID_VERIFICATION_CODE" {
                        self.alert = .verificationCodeInvalid
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
            }
        }
    }
    
    func validateUsername() {
        if !isUsernameValid {
            alert = .invalidUsernameInput
            return
        }
        
        isLoading = true
        
        authService.checkUsernameDuplication(username: username) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let isDuplicated = response.duplicated
                    if isDuplicated {
                        self.alert = .duplicatedUsername
                    } else {
                        self.signUp()
                    }
                case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
                }
            }
        }
    }

    func validatePassword() {
        if !isPasswordValid {
            alert = .invalidPasswordInput
        } else {
            proceedToUsername()
        }
    }
    
    func proceedToUsername() {
        navigationPath.append(.signUpCreateUsername)
    }
    
    func signUp() {
        isLoading = true
        authService.signUp(username: username, email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success: self.logIn()
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    // AuthView에 표시되는 email을 제외한 모든 개인 정보 필드를 초기화합니다.
    private func clearPrivacyData() {
        password = ""
        validationCode = ""
        username = ""
        isAlreadyVerified = false
    }
}

enum AuthAlert: Identifiable {
    case emailInvalid(message: String)
    case alreadyVerifiedEmail
    case resentVerifyCode
    case verificationCodeInvalid
    case sentResetPasswordMail
    case invalidPasswordInput
    case invalidUsernameInput
    case duplicatedUsername
    case exceededSendVerificationCodeLimit(email: String, dailyLimits: Int)
    case error(message: String)
    
    var id: String {
        switch self {
        case .emailInvalid: return "emailInvalid"
        case .alreadyVerifiedEmail: return "alreadyVerifiedEmail"
        case .resentVerifyCode: return "sentVerifyCode"
        case .verificationCodeInvalid: return "verificationCodeInvalid"
        case .sentResetPasswordMail: return "sentResetPasswordMail"
        case .invalidPasswordInput: return "invalidPasswordInput"
        case .invalidUsernameInput: return "invalidUsernameInput"
        case .duplicatedUsername: return "duplicatedUsername"
        case .exceededSendVerificationCodeLimit: return "exceededSendVerificationCodeLimit"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .emailInvalid(let message):
            return Alert(
                title: Text("올바르지 않은 이메일 주소"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .alreadyVerifiedEmail:
            return Alert(
                title: Text("인증 완료된 이메일 주소"),
                message: Text("이미 가입을 위해 인증을 완료한 이메일 주소예요. 바로 암호 설정 단계로 넘어갈게요."),
                dismissButton: .default(Text("확인"))
            )
        case .resentVerifyCode:
            return Alert(
                title: Text("인증 코드 새로 받기"),
                message: Text("새 인증 코드를 편지에 담아 보내드렸어요."),
                dismissButton: .default(Text("확인"))
            )
        case .verificationCodeInvalid:
            return Alert(
                title: Text("인증 코드 오류"),
                message: Text("올바르지 않은 인증 코드를 입력했어요. 인증 코드를 다시 확인해보세요."),
                dismissButton: .default(Text("확인"))
            )
        case .sentResetPasswordMail:
            return Alert(
                title: Text("암호 설정 편지 전송 완료"),
                message: Text("암호를 다시 설정할 수 있는 링크를 편지에 담아 보내드렸어요."),
                dismissButton: .default(Text("확인"))
            )
        case .invalidPasswordInput:
            return Alert(
                title: Text("올바르지 않은 암호"),
                message: Text("암호는 최소 8자부터 최대 64자까지의 길이로 설정해주세요."),
                dismissButton: .default(Text("확인"))
            )
        case .invalidUsernameInput:
            return Alert(
                title: Text("올바르지 않은 사용자 이름"),
                message: Text("사용자 이름은 최소 4자부터 최대 20자 길이여야 하며, 영문 소문자, 숫자, 밑줄(_), 마침표(.)만 사용할 수 있어요."),
                dismissButton: .default(Text("확인"))
            )
        case .duplicatedUsername:
            return Alert(
                title: Text("사용할 수 없는 사용자 이름"),
                message: Text("이미 다른 계정에서 사용되고 있는 사용자 이름이에요."),
                dismissButton: .default(Text("확인"))
            )
        case .exceededSendVerificationCodeLimit(let email, let dailyLimits):
            return Alert(
                title: Text("인증 코드 생성 제한"),
                message: Text("입력한 이메일 주소(\(email))는 가입을 위한 인증 코드를 만들 수 있는 최대 횟수를 초과했어요. 인증 코드는 이메일 주소 별로 하루 \(dailyLimits)번까지 만들 수 있으니, 내일 다시 시도해주세요."),
                dismissButton: .default(Text("확인"))
            )
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
