//
//  MyAccountGuestView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/31/26.
//

import SwiftUI

struct MyAccountGuestView: View {
    @EnvironmentObject private var router: Router
    private let authManager: AuthManager
    
    init(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                MyAccountHeader(nil, onEditProfileTapped: nil, onRegisterRecipeTapped: nil, onSettingsTapped: { self.router.push(.myAccountSettings) })
                coverSection
                bottomActionSection
            }
            .background(Color.backgroundPrimary)
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle(MainTabItems.myAccount.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
        }
    }
    
    private var coverSection: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("내 계정")
                    .font(.system(size: 30, weight: .bold))
                Text("나만의 레시피를 만들고, 가지고 있는 재료와 도구를 보관함에 추가해 체계적으로 관리할 수 있어요. 또한, EATZ에서의 모든 활동과 계정을 관리할 수 있어요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            .padding(20)
            Spacer()
        }
    }
    
    private var bottomActionSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                Image("handshake")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .foregroundStyle(Color.init(hex: "D1E7D7"))
                Button(action: authManager.requireAuthView) {
                    Text("이메일로 시작").frame(maxWidth: .infinity)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
                .accentColor(Color.init(hex: "55C374"))
                Text("로그인 또는 가입 후 계속 진행할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Color.init(hex: "93A197"))
            }
            .padding(20)
        }
    }
}

