//
//  LogInViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI

class LogInViewModel: ObservableObject {
    
    private lazy var authManager = AuthManager.shared
    
    @Published var password: String = ""
    @Published var statusMessage: String?
    @Published var isLoading = false
    
    func signIn(email: String, completion: @escaping () -> Void) {
        statusMessage = nil
        guard validatePassword() else { return }
        isLoading = true
        
        print("[SignInViewModel.signIn] 로그인을 요청할게요")
        authManager.logIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(()):
//                    self.authManager.loginPrompt = nil
                    print("성공")
                    completion()
//                    SheetManager.shared.sheet = nil
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("Alamofire 에러 \(afError.localizedDescription)")
                        self.statusMessage = networkError.userMessage
                    case .serverError(let errorResponse):
                        self.statusMessage = errorResponse.message
                    case .unknown:
                        self.statusMessage = "알 수 없는 이유로 로그인하지 못했어요. 다시 시도해보시겠어요?"
                    }
                }
            }
        }
    }
    
    func validatePassword() -> Bool {
        if password.isEmpty {
            statusMessage = "비밀 번호를 입력해주세요."
            return false
        }
        
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.count < 8 {
            statusMessage = "비밀 번호의 최소 길이는 8자이어야 해요."
            return false
        }
        
        if password.contains(where: { $0.isWhitespace }) {
            statusMessage = "비밀 번호에 공백이 포함돼선 안 돼요."
            return false
        }
        
        statusMessage = nil
        return true
    }
    
}
