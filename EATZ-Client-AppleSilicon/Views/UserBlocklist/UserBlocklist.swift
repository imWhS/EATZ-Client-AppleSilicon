//
//  UserBlocklist.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import SwiftUI

struct UserBlocklist: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Group {
            switch authManager.state {
            case .unknown: LoadingCurtain(title: "인증 상태를 확인하고 있어요...")
            case .unauthorized: CommonUnauthorizedStateView()
            case .authenticated(let user):
                // 현재 멤버의 ID가 변경되면 기존 UserBlocklistMemberView 인스턴스를 재렌더링하지 않고 소멸시킴으로써
                // 새 멤버의 데이터로 UserBlocklistMemberView 인스턴스를 생성합니다.
                UserBlocklistMemberView(authManager).id(user.id)
            }
        }
    }
}
