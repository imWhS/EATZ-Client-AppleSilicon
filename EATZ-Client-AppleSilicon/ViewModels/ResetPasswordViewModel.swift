//
//  ResetPasswordViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/17/25.
//

import SwiftUI

class ResetPasswordViewModel: ObservableObject {
    @Published var newPassword = ""
    @Published var state: ResetPasswordViewState = .validating
    @Published var email: String?
    @Published var alert: ResetPasswordAlert?
    
    private let token: String
    private var dismissAction: (() -> Void)?
    
    private let authService = AuthService.shared
    
    init(token: String) {
        self.token = token
    }
    
    func setDismissAction(_ action: @escaping () -> Void) {
        dismissAction = action
    }
    
    func validateToken() {
        state = .validating
        
        authService.validateResetPasswordToken(token: token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.email = response.email
                    self.state = .idle
                case .failure(let error):
                    self.alert = .invalidLink(message: error.userMessage, dismissAction: self.dismissAction ?? {})
                    self.state = .validationFailed
                }
            }
        }
    }
    
    func resetPassword(onSuccess: @escaping () -> Void) {
        state = .resetting
        authService.submitNewPasswordForReset(token: token, newPassword: newPassword) { [weak self] result in
            guard let self = self else { return }
            self.state = .idle
            
            switch result {
            case .success((())):
                self.alert = .resetSuccess(confirmAction: onSuccess)
            case .failure(let networkError):
                self.alert = .resetFailed(message: networkError.userMessage)
            }
        }
    }
}

enum ResetPasswordAlert: Identifiable {
    case invalidLink(message: String, dismissAction: () -> Void)
    case resetFailed(message: String)
    case resetSuccess(confirmAction: () -> Void)
    
    var id: String {
        switch self {
        case .invalidLink: return "invalidLink"
        case .resetFailed: return "resetFailed"
        case .resetSuccess: return "resetSuccess"
        }
    }
    
    var alert: Alert {
        switch self {
        case .invalidLink(let message, let dismissAction):
            return Alert(
                title: Text("유효하지 않은 요청"),
                message: Text(message),
                dismissButton: .default(Text("확인"), action: dismissAction)
            )
        case .resetFailed(let message):
            return Alert(
                title: Text("암호 설정 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .resetSuccess(let confirmAction):
            return Alert(
                title: Text("암호 설정 완료"),
                message: Text("입력한 새 암호로 설정했어요."),
                dismissButton: .default(Text("확인"), action: confirmAction)
            )
        }
    }
}

enum ResetPasswordViewState {
    case validating
    case idle
    case validationFailed
    case resetting
}
