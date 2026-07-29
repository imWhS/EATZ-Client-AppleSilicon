//
//  EATZ_Client_AppleSiliconApp.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/15/25.
//

import SwiftUI

@main
struct EATZ_Client_AppleSiliconApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isFirstActive = true
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .onChange(of: scenePhase) { _, scenePhase in
            /// 앱이 foreground 상태로 전환됐을 때, 여전히 세션이 유효한지 검증합니다.
            if scenePhase == .active {
                AuthGlobalPresenter.shared.processPendingDeepLink()
                
                if isFirstActive {
                    // 앱을 실행한 직후에는 AuthManager.checkInitialState()를 통해 세션 유효성 검증을 진행하기 때문에 여기에서 세션 유효성 검증을 진행하지 않습니다.
                    isFirstActive = false
                } else {
                    print("[APP] 앱이 foreground 상태로 전환됐어요. 세션 유효성 검증을 시작할게요.")
                    authManager.validateSession()
                }
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        // Ex. eatz://reset-password?emailVerificationToken=...
        if components.scheme == "eatzuserauth" && components.host == "reset-password" {
            if let token = components.queryItems?.first(where: { $0.name == "emailVerificationToken" })?.value {
                
                print("[DBG] handleDeppLink - token: \(token)")
                // 뷰를 present 하기 전, GlobalPresenter에 토큰 저장부터 합니다.
                AuthGlobalPresenter.shared.setPendingResetPasswordToken(token)

                // 만약 앱이 이미 켜져있는 상태(Warm Start)에서 딥 링크를 받았다면, scenePhase가 바뀌지 않으므로 여기서 즉시 실행을 시도할 수도 있습니다.
                if UIApplication.shared.applicationState == .active {
                   AuthGlobalPresenter.shared.processPendingDeepLink()
                }
            }
        }
    }
}
