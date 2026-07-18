//
//  ResetPasswordView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/17/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel: ResetPasswordViewModel
    @FocusState private var isFocusedPassword: Bool
    @State private var isPasswordVisible: Bool = false
    
    let dismissAction: () -> Void
    let completionAction: () -> Void
    
    init(token: String, completionAction: @escaping () -> Void, dismissAction: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(token: token))
        self.completionAction = completionAction
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        mainContent
            .onAppear { viewModel.validateToken() }
            .alert(item: $viewModel.alert) { $0.alert }
    }
    
    private var mainContent: some View {
        VStack {
            ResetPasswordHeader(onCancel: dismissAction)

            switch viewModel.state {
            case .validating: LoadingCurtain(title: "올바른 요청인지 확인하고 있어요...")
            case .idle, .resetting:
                if let email = viewModel.email {
                    ResetPasswordSetupView(
                        password: $viewModel.newPassword,
                        isFocused: $isFocusedPassword,
                        isPasswordVisible: $isPasswordVisible,
                        email: viewModel.email!,
                        isSubmitable: viewModel.state != .resetting,
                        onSubmit: { viewModel.resetPassword(onSuccess: completionAction) })
                }
            case .validationFailed: ErrorCurtain("올바르지 않거나, 만료된 링크로 접근하신 것 같아요. 처음부터 다시 시도해주세요.")
            }
        }
        .background(Color.init(hex: "F9F9F9"))
    }
}

private struct ResetPasswordHeader: View {
    let onCancel: () -> Void

    var body: some View {
        HStack {
            Text("계정")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            DismissButton(action: onCancel)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}

private struct ResetPasswordSetupView: View {
    @Binding var password: String
    @FocusState.Binding var isFocused: Bool
    @Binding var isPasswordVisible: Bool
    
    let email: String
    let isSubmitable: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            instructionView
            passwordFields
            Spacer()
            submitButton
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 12) {
            Text("암호 다시 설정")
                .font(.system(size: 30, weight: .bold))
            VStack(spacing: 8) {
                Group {
                    Text("'\(email)' 이메일 주소로 가입한 계정의 새 암호를 설정합니다.")
                }
                .font(Font.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.init(hex: "A5A5A5"))
                .lineLimit(nil)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var passwordFields: some View {
        ZStack {
            FloatingTitleTextField(title: "새 암호", placeholder: nil, text: $password, isFocused: $isFocused)
                .padding(.horizontal, 20)
                .opacity(isPasswordVisible ? 1 : 0)
                .disabled(!isPasswordVisible)
            FloatingTitleSecureField(title: "새 암호", placeholder: nil, text: $password, isFocused: $isFocused)
                .padding(.horizontal, 20)
                .opacity(isPasswordVisible ? 0 : 1)
                .disabled(isPasswordVisible)
        }
    }
    
    @ViewBuilder
    private var submitButton: some View {
        Group {
            if !isSubmitable { ProgressView() }
            else {
                Button(action: onSubmit) {
                    HStack {
                        Text("완료").font(.system(size: 17, weight: .semibold))
                        Image("arrow-right-14")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
            }
        }
        .padding(20)
    }
}
