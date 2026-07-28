//
//  PlannerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/2/25.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @State private var alert: PlannerAlert?
    
    var body: some View {
        Group {
            switch authManager.state {
            case .unknown: LoadingCurtain(title: "인증 상태를 확인하고 있어요...")
            case .unauthorized: PlannerGuestView(authManager)
            case .authenticated(let user):
                // 현재 멤버의 ID가 변경되면 기존 PlannerMemberView 인스턴스를 재렌더링하지 않고 소멸시킴으로써
                // 새 멤버의 데이터로 PlannerMemberView 인스턴스를 생성합니다.
                PlannerMemberView(authManager).id(user.id)
            }
        }
        .background(Color(hex: "F9F9F9"))
        .onChange(of: authManager.state, isSessionExpired)
        .alert(
            alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $alert),
            presenting: alert,
            actions: { $0.actions },
            message: { $0.message })
    }
    
    private func isSessionExpired(oldState: AuthState, newState: AuthState) {
        if case .authenticated = oldState, case .unauthorized = newState {
            self.alert = .sessionExpired
        }
    }
}

enum PlannerAlert {
    case sessionExpired
    case error(message: String)
    
    var title: String {
        switch self {
        case .sessionExpired: "세션 만료"
        case .error: "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .sessionExpired: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .sessionExpired: Text("이전의 사용자가 로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(let message): Text(message)
        }
    }
}

