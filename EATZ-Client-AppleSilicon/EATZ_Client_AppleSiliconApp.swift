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
    @StateObject private var systemManager = SystemManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isFirstActive = true
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    systemManager.handleDeepLinkForResetPassword(url)
                }
                .alert(
                    systemManager.alert?.title ?? "",
                    isPresented: Binding.init(isPresenting: $systemManager.alert),
                    presenting: systemManager.alert,
                    actions: { $0.actions },
                    message: { $0.message })
                .sheet(item: $systemManager.launchNotice) { launchNotice in
                    LaunchNoticeView(
                        id: launchNotice.id,
                        title: launchNotice.title,
                        markdownContent: launchNotice.markdownContent,
                        isForce: launchNotice.force
                    )
                }
        }
        .onChange(of: scenePhase) { _, scenePhase in
            /// 앱이 foreground 상태로 전환됐을 때, 여전히 세션이 유효한지 검증합니다.
            if scenePhase == .active {
                AuthGlobalPresenter.shared.processPendingDeepLink()
                systemManager.validateClientVersion()
                
                if isFirstActive {
                    systemManager.loadLaunchNotice()
                    
                    // 앱을 실행한 직후에는 AuthManager.checkInitialState()를 통해 세션 유효성 검증을 진행하기 때문에 여기에서 세션 유효성 검증을 진행하지 않습니다.
                    isFirstActive = false
                } else {
                    print("[APP] 앱이 foreground 상태로 전환됐어요. 세션 유효성 검증을 시작할게요.")
                    authManager.validateSession()
                }
            }
        }
    }
}
