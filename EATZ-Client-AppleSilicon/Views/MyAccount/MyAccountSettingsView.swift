//
//  MyAccountSettingsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/23/26.
//

import SwiftUI

struct MyAccountSettingsView: View {
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var authManager: AuthManager
    @State private var alert: MyAccountSettingsAlert?
    
    var clientBuildNumber: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
   }
    
    var iOSClientVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        if let buildNumber = clientBuildNumber {
            return "iOS - \(version) (\(buildNumber))"
        } else {
            return "iOS - \(version)"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 20) {
                    if authManager.isLoggedIn {
                        SettingsSectionCard(title: "계정 관리") {
                            BasicMenuRow("차단 사용자 관리", false) {
                                router.push(.userBlocklist)
                            }
                        }
                    }
                    
                    SettingsSectionCard(title: "사용자 지원") {
                        BasicMenuRow("새로운 소식", .externalLink) {
                            if let url = EatzLinks.newsAndUpdatesURL {
                                openURL(url)
                            }
                        }
                        BasicMenuRow("개발자에게 편지 쓰기", false, .externalLink, EatzLinks.developerEmailString) {
                            if let url = SupportEmailUtli.createEmailURL() {
                                openURL(url)
                            }
                        }
                    }
                    
                    SettingsSectionCard(title: "정보") {
                        BasicMenuRow("이용 약관 및 정책", .externalLink) {
                            if let url = EatzLinks.termsOfServiceURL {
                                openURL(url)
                            }
                        }
                        BasicMenuRow("개인 정보 처리 방침", .externalLink) {
                            if let url = EatzLinks.privacyPolicyURL {
                                openURL(url)
                            }
                        }
                        BasicMenuRow("Open Source License") {
                            router.push(.openSourceLicense)
                        }
                        BasicMenuRow("버전", false, .info(trailing: iOSClientVersion)) {
                            print("버전 확인")
                        }
                    }
                    if authManager.isLoggedIn {
                        HStack {
                            Button("로그아웃", action: handleLogOutAction)
                                .buttonStyle(RoundedButtonStyle(.danger, .medium))
                            
                            Button(action: { router.push(.deleteAccount) } ) {
                                HStack {
                                    Text("회원 탈퇴")
                                    Image("arrow-right-6.8")
                                }
                            }
                            .buttonStyle(RoundedButtonStyle(.danger, .medium))
                        }
                    }
                }
                .padding(.top, 20)
                
                footer
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("설정 및 정보")
        .alert(
            alert?.title ?? "",
            isPresented: Binding(
                get: { self.alert != nil },
                set: { isPresented in if !isPresented { self.alert = nil } }),
            presenting: alert,
            actions: { $0.actions },
            message: { $0.message })
    }
    
    private func handleLogOutAction() {
        guard let username = authManager.currentUser?.username else { return }
        alert = .confirmLogOut(username: username, logOutAction: authManager.logOut)
    }
    
    private var footer: some View {
        VStack(spacing: 6) {
            Group {
                HStack {
                    Text("EATZ")
                        .font(.system(size: 14, weight: .bold))
                }
                VStack(spacing: 2) {
                    Group {
                        Text("© 2026 Wonhee Son. All rights reserved.")
                        Link(EatzLinks.developerEmailString, destination: URL(string: EatzLinks.developerEmailString)!)
                        Link("github.com/imWhS", destination: URL(string: "https://github.com/imWhS")!)
                    }
                    .font(.system(size: 10, weight: .medium))
                }
            }
            .foregroundStyle(Color.gray20)
            .tint(Color.gray20)
        }
        .padding(.vertical, 20)
    }
}

enum MyAccountSettingsAlert {
    case confirmLogOut(username: String, logOutAction: () -> Void)
    
    var title: String {
        switch self {
        case .confirmLogOut: return "계정 로그아웃"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmLogOut(_, let logOutAction):
            Button("로그아웃", role: .destructive, action: logOutAction)
            Button("취소", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmLogOut(let username, _): Text("지금 사용 중이신 \(username) 계정을 로그아웃하시겠어요?")
        }
    }
    
}

struct SettingsSectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let title = title {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(14)
            .padding(.horizontal, 20)
        }
    }
}
