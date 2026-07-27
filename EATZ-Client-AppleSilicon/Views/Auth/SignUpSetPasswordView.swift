//
//  SignUpAdditionPasswordView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/13/25.
//

import SwiftUI

struct SignUpSetPasswordView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @FocusState private var isPasswordFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            header
            VStack(spacing: 10) {
                PasswordView(password: $viewModel.password, isFocused: $isPasswordFocused, isPasswordVisible: $isPasswordVisible, onSubmit: viewModel.validatePassword)
                showPasswordToggleView
            }
            Spacer()
        }
        .background(Color.init(hex: "F9F9F9"))
        .toolbar {
            titleToolbarItem
            doneToolbarItem
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("암호 설정")
                .font(.system(size: 30, weight: .bold))
            Text(viewModel.email)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.init(hex: "7F7F7F"))
                .padding(.horizontal, 10)
                .frame(height: 22)
                .cornerRadius(11)
                .border(color: .init(hex: "E5E5E5"), width: 1)
            VStack(spacing: 8) {
                Group {
                    Text("위 이메일 주소로 계정을 새로 만듭니다. 로그인할 때 사용할 암호를 입력하세요.")
                    Text("암호는 최소 8자리 이상의 길이여야 합니다.")
                }
                .font(Font.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.init(hex: "A5A5A5"))
                .lineLimit(nil)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private struct PasswordView: View {
        @Binding var password: String
        @FocusState.Binding var isFocused: Bool
        @Binding var isPasswordVisible: Bool
        
        let onSubmit: () -> Void
        
        var body: some View {
            ZStack {
                FloatingTitleTextField(title: "암호", placeholder: nil, text: $password, isFocused: $isFocused, onSubmit: onSubmit)
                    .padding(.horizontal, 20)
                    .opacity(isPasswordVisible ? 1 : 0)
                    .disabled(!isPasswordVisible)
                FloatingTitleSecureField(title: "암호", placeholder: nil, text: $password, isFocused: $isFocused, onSubmit: onSubmit)
                    .padding(.horizontal, 20)
                    .opacity(isPasswordVisible ? 0 : 1)
                    .disabled(isPasswordVisible)
            }
        }
    }
    
    private var showPasswordToggleView: some View {
        Toggle(isOn: $isPasswordVisible) {
            Text("암호 보기")
                .font(.system(size: 14, weight: .medium))
        }
        .tint(.accent)
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("이메일 인증")
                .opacity(0)
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: viewModel.validatePassword) {
                Text("완료").font(.system(size: 17, weight: .semibold))
            }
            .disabled(viewModel.password.count < 8)
        }
    }
}

#Preview {
    SignUpSetPasswordView()
}
