//
//  SignUpCreationUsernameView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/13/25.
//

import SwiftUI

struct SignUpCreationUsernameView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @FocusState private var isUsernameFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            header
            usernameFieldView
            Spacer()
        }
        .background(Color.backgroundPrimary)
        .toolbar {
            titleToolbarItem
            doneToolbarItem
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("사용자 이름 추가")
                .font(.system(size: 30, weight: .bold))
            Text(viewModel.email)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray35)
                .padding(.horizontal, 10)
                .frame(height: 22)
                .cornerRadius(11)
                .border(color: .init("E5E5E5"), width: 1)
            VStack(spacing: 8) {
                Group {
                    Text("위 이메일 주소로 계정을 새로 만듭니다. 회원님을 나타낼 사용자 이름을 입력하세요.")
                    Text("사용자 이름은 EATZ에서 ‘나'를 나타내면서, 다른 사람과 구별하는 데에 사용해요.")
                    Text("사용자 이름은 나중에 변경할 수 없어요.")
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
    
    private var usernameFieldView: some View {
        FloatingTitleTextField(
            title: "사용자 이름",
            placeholder: nil,
            isInvalid: false,
            text: $viewModel.username,
            isFocused: $isUsernameFocused,
            isAutocorrectionDisabled: true,
            capitalization: .never,
            keyboardType: .default,
            onSubmit: { viewModel.signUp() }
        )
        .padding(.horizontal, 20)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.5 : 1)
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("이메일 인증")
                .opacity(0)
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: viewModel.signUp) {
                Text("완료").fontWeight(.semibold)
            }
            .fontWeight(.semibold)
            .tint(Color.auth)
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.password.isEmpty)
        }
    }
}
