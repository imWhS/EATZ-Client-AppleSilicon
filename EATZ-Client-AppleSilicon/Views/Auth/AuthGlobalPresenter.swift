//
//  AuthGlobalPresenter.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/21/25.
//

import SwiftUI

class AuthGlobalPresenter {
    // MARK: - 싱글톤 객체 프로퍼티
    
    static let shared = AuthGlobalPresenter()
    
    // MARK: - 비공개 프로퍼티
    
    private var isResetPasswordViewPresented = false
    private var pendingResetToken: String?
    
    /// 현재 AuthView의 화면 표시 여부 플래그입니다.
    private var isAuthViewPresented = false
    private var loginDidSucceed = false

    private init() {}
    
    // MARK: - 공개 메서드
    
    func setPendingResetPasswordToken(_ token: String) {
        pendingResetToken = token
    }
    
    func processPendingDeepLink() {
        // 보류 중인 토큰이 없으면 실행을 멈춥니다.
        guard let token = pendingResetToken else { return }

        // 중복 실행을 방지하기 위해, 토큰을 nil로 초기화합니다.
        pendingResetToken = nil

        presentResetPasswordView(token: token)
    }
    
    
    func presentResetPasswordView(token: String) {
        if isResetPasswordViewPresented { return }
        
        isResetPasswordViewPresented = true
        
        let resetPasswordView = AuthResetPasswordView(
            token: token,
            onComplete: dismissResetPasswordView,
            onDismiss: dismissResetPasswordView
        )
        
        let hostingController = UIHostingController(rootView: resetPasswordView)
        hostingController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            guard let topViewController = UIApplication.shared.topViewController() else {
                self.isResetPasswordViewPresented = false
                
                print("[GlobalPresenter.presentResetPasswordView] 상위 계층의 뷰 컨트롤러가 없어요. ")
                return
            }
            
            topViewController.present(hostingController, animated: true) {
//                onPresented?()
//                self.dismissResetPasswordView()
            }
        }
    }

    /// 앱의 뷰 최상단 계층에 AuthView를 present 합니다.
    func presentAuthView(context: AuthContext, onPresented: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        // 이미 AuthView가 present 된 상태면, 더 이상 실행하지 않습니다.
        if isAuthViewPresented { return }
        
        // AuthView의 중복 present를 예방합니다.
        isAuthViewPresented = true
        
        loginDidSucceed = false

        // AuthView 인스턴스를 정의하면서, 로그인 성공 또는 미진행 상황 발생 시 실행할 클로저도 함께 정의합니다.
        let authView = AuthView(
            context: context,
            onLogInSuccess: { accessToken, user in
                // AuthView에서 로그인 성공 시: AuthView를 닫고, AuthManager에게 결과를 전달합니다.
                print("[GlobalPresenter.presentAuthView] AuthView에서 \(user.username) 사용자의 로그인을 성공했어요. AuthView를 dismiss 하고, AuthManager에게 로그인 후속 처리를 요청할게요.")
                self.loginDidSucceed = true
                self.dismissAuthView()
                AuthManager.shared.setStateAsAuthenticated(accessToken: accessToken, user: user)},
            onDismiss: {
                // AuthView에서 로그인 미진행 시: AuthView를 닫고, AuthManager에게 로그아웃 처리를 요청합니다.
                if !self.loginDidSucceed {
                    print("[GlobalPresenter.presentAuthView] AuthView에서 로그인을 취소했어요. AuthView를 dismiss 하고, AuthManager에게 로그아웃 처리를 요청할게요.")
                    self.dismissAuthView()
                    onDismiss?()
                    AuthManager.shared.logOut()}}
        )
        
        let hostingController = UIHostingController(rootView: authView)
        hostingController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            guard let topViewController = UIApplication.shared.topViewController() else {
                self.isAuthViewPresented = false
                
                print("[GlobalPresenter.presentAuthView] 상위 계층의 뷰 컨트롤러가 없어요. ")
                return
            }
            
            topViewController.present(hostingController, animated: true) {
                onPresented?()
            }
        }
    }
    
    // MARK: - 비공개 메서드
    
    /// AuthView를 dismiss 합니다.
    private func dismissAuthView() {
        guard isAuthViewPresented, let topViewController = UIApplication.shared.topViewController() else { return }
        
        if topViewController is UIHostingController<AuthView> {
            topViewController.dismiss(animated: true) {
                self.isAuthViewPresented = false
            }
        } else {
            // AuthView 위에 다른 뷰가 present 된 상황인 경우: 플래그만 초기화
            isAuthViewPresented = false
        }
    }
    /// AuthView를 dismiss 합니다.
    private func dismissResetPasswordView() {
        guard isResetPasswordViewPresented, let topViewController = UIApplication.shared.topViewController() else { return }
        
        if topViewController is UIHostingController<AuthResetPasswordView> {
            topViewController.dismiss(animated: true) {
                self.isResetPasswordViewPresented = false
            }
        } else {
            // AuthView 위에 다른 뷰가 present 된 상황인 경우: 플래그만 초기화
            isResetPasswordViewPresented = false
        }
    }
}
