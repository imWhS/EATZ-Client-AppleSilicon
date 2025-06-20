//
//  LogInViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/17/25.
//

import Foundation

class SignInViewModel: ObservableObject {
    private lazy var authManager = AuthManager.shared
    
    @Published var email: String = "admin@eatz.io"
    @Published var password: String = "1q2w3e4r!"
    @Published var isLoading = false
    @Published var statusMessage: String = "대기 중"
    
    func logIn() {
        statusMessage = "로그인 요청 준비 중..."
        authManager.logIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(()):
                    self.statusMessage = "로그인 완료"
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.statusMessage = afError.localizedDescription
                    case .serverError(let errorResponse):
                        self.statusMessage = errorResponse.message
                    case .unknown:
                        self.statusMessage = "알 수 없는 이유로 로그인하지 못했어요. 다시 시도해보시겠어요?"
                    }
                }
            }
        }
    }
    
//    func logOut() {
//        authManager.()
//    }
    
}
