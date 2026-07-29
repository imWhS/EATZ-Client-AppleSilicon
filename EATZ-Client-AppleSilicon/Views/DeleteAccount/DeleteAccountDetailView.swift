//
//  DeleteAccountDetailView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/25/26.
//

import SwiftUI

struct DeleteAccountDetailView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel = DeleteAccountDetailViewModel()
    @FocusState var isFocused: Bool
    
    private var email: String { authManager.currentUser?.email ?? "" }
    
    var body: some View {
        Group {
            switch authManager.state {
            case .unknown: LoadingCurtain(title: "인증 상태를 확인하고 있어요...")
            case .unauthorized: CommonUnauthorizedStateView()
            case .authenticated(let user): contentView.id(user.id)
            }
        }
        .navigationTitle("회원 탈퇴 확인")
        .toolbar {
            doneToolbarItem
        }
        .task {
            viewModel.authManager = authManager
            viewModel.prepareDataIfNeeded()
        }
        .onChange(of: viewModel.routingAction) { _, routingAction in
            switch routingAction {
            case .dismiss: router.popToRoot()
            case .none: break
            }
        }
        .onChange(of: authManager.state, isSessionExpired)
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: viewModel.deleteAccount) {
                Text("완료").font(.system(size: 17, weight: .semibold))
            }
            .disabled(viewModel.password.isEmpty)
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                passwordSection
            }
            Spacer()
        }
        .background(Color.backgroundPrimary)
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("암호")
                .font(.system(size: 30, weight: .bold))
            Text("'\(email)' 이메일 주소로 가입한 계정에 설정한 암호를 입력하세요.")
                .font(Font.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
                .lineLimit(nil)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var passwordSection: some View {
        VStack(spacing: 10) {
            LogInPasswordField(
                password: $viewModel.password,
                isFocused: $isFocused,
                isPasswordVisible: $viewModel.isPasswordVisible,
                onLogIn: {})
            showPasswordToggle
        }
    }
    
    private var showPasswordToggle: some View {
        Toggle(isOn: $viewModel.isPasswordVisible) {
            Text("암호 보기")
                .font(.system(size: 14, weight: .medium))
        }
        .tint(.accent)
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
    
    private func isSessionExpired(oldState: AuthState, newState: AuthState) {
        if case .authenticated = oldState, case .unauthorized = newState {
            viewModel.alert = .sessionExpired
        }
    }
}
