//
//  SignUpCreateUsernameView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/13/25.
//

import SwiftUI

struct SignUpCreateUsernameView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @FocusState private var isUsernameFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    private var navigationTitleLabel: String = "사용자 이름 설정"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                usernameFieldView
                GuideView(guides: [
                    "사용자 이름은 최소 4자부터 최대 20자까지의 길이로 구성되어야 하며, 알파벳 소문자, 숫자, 밑줄(_), 마침표(.)만 사용할 수 있어요.",
                    "사용자 이름은 나중에 변경할 수 없어요."
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
                    Text("위 이메일 주소로 계정을 새로 만들어요. 회원님을 나타낼 사용자 이름을 입력하세요.")
                    Text("사용자 이름은 EATZ에서 ‘나'를 나타내면서, 다른 사람과 구별하는 데에 사용해요.")
                }
                .font(Font.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
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
            keyboardType: .asciiCapable,
            onSubmit: viewModel.validateUsername
        )
        .padding(.horizontal, 20)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.5 : 1)
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(navigationTitleLabel)
                .opacity(0)
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: viewModel.validateUsername) {
                Text("완료")
            }
            .fontWeight(.semibold)
            .tint(Color.auth)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isUsernameValid)
        }
    }
}
