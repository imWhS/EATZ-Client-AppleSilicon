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
    
    private var navigationTitleLabel: String = "암호 설정"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                VStack(spacing: 10) {
                    PasswordView(
                        password: $viewModel.password,
                        isFocused: $isPasswordFocused,
                        isPasswordVisible: $isPasswordVisible,
                        onSubmit: viewModel.validatePassword)
                    showPasswordToggleView
                }
                GuideView(guides: [
                    "암호는 최소 8자부터 최대 64자까지의 길이로 구성되어야 해요."
                ])
                Spacer()
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(navigationTitleLabel)
        .toolbar {
            titleToolbarItem
            doneToolbarItem
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text(navigationTitleLabel)
                .font(.system(size: 30, weight: .bold))
            Text(viewModel.email)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray50)
                .padding(.horizontal, 10)
                .frame(height: 22)
                .cornerRadius(11)
                .border(color: .gray8, width: 1)
            VStack(spacing: 8) {
                Group {
                    Text("위 이메일 주소로 계정을 새로 만들어요. 로그인할 때 사용할 암호를 입력하세요.")
                }
                .font(Font.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
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
                FloatingTitleTextField(title: "암호", placeholder: nil, isInvalid: false, text: $password, isFocused: $isFocused, onSubmit: onSubmit)
                    .padding(.horizontal, 20)
                    .opacity(isPasswordVisible ? 1 : 0)
                    .disabled(!isPasswordVisible)
                    .tint(Color.auth)
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
        .tint(Color.auth)
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(navigationTitleLabel)
                .opacity(0)
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: viewModel.validatePassword) {
                Text("완료")
            }
            .fontWeight(.semibold)
            .tint(Color.auth)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isPasswordValid)
        }
    }
}

#Preview {
    SignUpSetPasswordView()
}
