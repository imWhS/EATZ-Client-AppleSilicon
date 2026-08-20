//
//  LogInView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

struct LogInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        mainContent
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
               if viewModel.isLoading { ProgressView() }
                else {
                   Button("완료", action: viewModel.logIn)
                        .fontWeight(.semibold)
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.isPasswordValid)
               }
           }
        }
        .onAppear { isFocused = true }
        .alert(item: $viewModel.alert) { $0.alert }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    passwordSection
                }
                Spacer()
            }
            resetPasswordSection
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("암호")
                .font(.system(size: 30, weight: .bold))
            Text("'\(viewModel.email)' 이메일 주소로 가입한 계정으로 로그인하려면, 설정한 암호를 입력하세요.")
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
                isPasswordVisible: $isPasswordVisible,
                onLogIn: viewModel.logIn)
            showPasswordToggle
        }
    }
    
    private var showPasswordToggle: some View {
        Toggle(isOn: $isPasswordVisible) {
            Text("암호 보기")
                .font(.system(size: 14, weight: .medium))
        }
        .tint(.accent)
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
    
    private var resetPasswordSection: some View {
        VStack(alignment: .center, spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                if viewModel.isLoadingForResetPassword {
                    ProgressView()
                } else {
                    Button("암호 다시 설정", action: viewModel.resetPassword)
                        .buttonStyle(CapsuleButtonMediumStyle(status: .authSecondary))
                }
                
                Group {
                    if viewModel.isLoadingForResetPassword {
                        Text("가입한 이메일 주소로 암호를 다시 설정할 수 있는 링크가 포함된 편지를 보내고 있어요...")
                    } else {
                        Text("암호가 기억나지 않는다면, 새 암호로 설정해보세요.")
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
            }
            .padding(20)
        }
    }
}

