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
    
    @StateObject private var errorManager = ErrorManager.shared
    
    @StateObject private var sheetManager = ModalManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(authManager)
                .environmentObject(errorManager)
                .environmentObject(sheetManager)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active, authManager.isLoggedIn {
                print("<APP> 인증 상태 확인을 위해 서버에 토큰 재발급을 요청할게요.")
                authManager.reissueTokens { _ in
                    authManager.fetchCurrentUser()
                }
            }
            
            if !(authManager.isLoggedIn) {
                print("<App> 전역 비로그인 상태여서, AuthManager에게 로그아웃 처리를 요청할게요.")
                authManager.clearTokens()
            }
        }
    }
}
