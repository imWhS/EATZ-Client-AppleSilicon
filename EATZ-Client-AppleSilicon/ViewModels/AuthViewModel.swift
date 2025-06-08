//
//  AuthViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI

/**
 `AuthViewModel`은 계정 메인 화면에서 필요한 상태를 관리하는 뷰 모델입니다.
 뷰에서는 이 뷰 모델의 상태를 구독해 UI를 업데이트 할 수 있습니다.
 
 이 뷰 모델은 아래와 같은 역할을 합니다.
 - 사용자가 입력한 이메일 주소를 저장합니다.
 - 이메일 주소가 유효한지 검증합니다.
 */
class AuthViewModel: ObservableObject {
    
    var authManager = AuthManager.shared
    
    @Published var email: String = ""
    @Published var validationMessage: String?
    
    func validateEmail() -> Bool {
        validationMessage = nil
        
        if email.isEmpty {
            validationMessage = "이메일 주소를 입력해주세요."
            return false
        }
        
        if !email.isValidEmail {
            validationMessage = "올바른 형태의 이메일 주소인지 확인해주세요."
            return false
        }
        
        return true
    }
    
}
