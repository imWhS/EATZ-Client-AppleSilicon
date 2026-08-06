//
//  SystemManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/6/26.
//

import SwiftUI

final class SystemManager: ObservableObject {
    static let shared = SystemManager()
    
    @Published var launchNotice: SystemClientLaunchNotice?
    @AppStorage("LastViewedLaunchNoticeId") private var lastViewedLaunchNoticeId: Int = 0
    
    @Published var presentSystemAlert = false
    @Published var systemTitle = ""
    @Published var systemMessage = ""
    
    @Published var needsForceUpdate = false
    
    @Published var alert: SystemAlert?
    
    private var clientVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private init() {}
    
    func loadLaunchNotice() {
        SystemService.shared.fetchLaunchNotice { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let launchNotice):
                    if launchNotice.force || self.lastViewedLaunchNoticeId < Int(launchNotice.id) {
                        self.launchNotice = launchNotice
                    }
                case .failure(let networkError):
                    self.alert = .error(title: "런치 알림 확인 실패", message: "\(networkError.userMessage)")
                }
            }
        }
    }
    
    func markNoticeAsViewed(id: Int64, doNotShowAgain: Bool) {
        if doNotShowAgain {
            lastViewedLaunchNoticeId = Int(id)
        }
        
        launchNotice = nil
    }
    
    func validateClientVersion() {
        SystemService.shared.getClientVersion { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let required = response.requiredVersion
                    let latest = response.latestVersion
                    
                    let isForceUpdateRequired = self.clientVersion.compare(required, options: .numeric) == .orderedAscending
                    let isUpdateOptional = self.clientVersion.compare(latest, options: .numeric) == .orderedAscending
                    
                    if isForceUpdateRequired {
                        self.alert = .forceUpdateRequired(
                            message: response.message,
                            requiredVersion: required,
                            currentVersion: self.clientVersion,
                            confirmAction: {
                                self.openAppStore()
                                self.validateClientVersion()
                            })
                        self.needsForceUpdate = true
                    } else if isUpdateOptional {
                        self.alert = .updatable(message: response.message, latestVersion: latest, confirmAction: self.openAppStore)
                    }
                case .failure(let networkError):
                    self.alert = .error(title: "버전 확인 실패", message: "버전을 확인하지 못했어요. \(networkError.userMessage)")
                }
            }
        }
    }
    
    func handleDeepLinkForResetPassword(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        // Ex. eatz://reset-password?emailVerificationToken=...
        if components.scheme == "eatzuserauth" && components.host == "reset-password" {
            if let token = components.queryItems?.first(where: { $0.name == "emailVerificationToken" })?.value {
                
                // 뷰를 present 하기 전, GlobalPresenter에 토큰 저장부터 합니다.
                AuthGlobalPresenter.shared.setPendingResetPasswordToken(token)

                if UIApplication.shared.applicationState == .active {
                   AuthGlobalPresenter.shared.processPendingDeepLink()
                }
            }
        }
    }
    
    private func openAppStore() {
        let appleId = "6796143243"
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appleId)") {
            UIApplication.shared.open(url)
        }
    }
}

enum SystemAlert {
    case forceUpdateRequired(message: String?, requiredVersion: String, currentVersion: String, confirmAction: () -> Void)
    case updatable(message: String?, latestVersion: String, confirmAction: () -> Void)
    case error(title: String?, message: String)
    
    var title: String {
        switch self {
        case .forceUpdateRequired: "업데이트 필요"
        case .updatable: "새 버전 출시 알림"
        case .error(let title, _): title ?? "오류"
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .forceUpdateRequired(let message, let requiredVersion, let currentVersion, _):
            Text(message ?? "\(requiredVersion) 버전으로 업데이트 후 EATZ를 이용할 수 있어요. 지금 \(currentVersion) 버전을 사용하고 있어요.")
        case .updatable(let message, let latestVersion, _):
            Text(message ?? "\(latestVersion) 버전으로 업데이트할 수 있어요.")
        case .error(_, let message):
            Text(message)
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .forceUpdateRequired(_, _, _, let confirmAction):
            Button("지금 업데이트", action: confirmAction).keyboardShortcut(.defaultAction)
        case .updatable(_, _, let confirmAction):
            Button("나중에 업데이트") {}
            Button("지금 업데이트", action: confirmAction).keyboardShortcut(.defaultAction)
        case .error(_, _):
            Button("확인") {}
        }
    }
}
