//
//  SignUpEmailVerificationView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

struct SignUpEmailVerificationView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @FocusState private var isValidationCodeFocused: Bool
    
    private var navigationTitle: String = "이메일 인증"
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    if viewModel.isAlreadyVerified {
                        Button(action: viewModel.verifyValidationCode) {
                            HStack {
                                Text("다음")
                                Image("arrow-right-14")
                            }
                        }
                        .buttonStyle(CapsuleLargeButtonStyle(appearance: .authPrimary))
                    } else {
                        validationCodeFieldView
                    }
                }
                Spacer()
            }
            resendSection
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(navigationTitle)
        .toolbar {
            titleToolbarItem
        }
        .onChange(of: viewModel.validationCode) {
            viewModel.validateValidationCode()
        }
        .onAppear {
            viewModel.lastValidationCode = viewModel.validationCode
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text(navigationTitle)
                .font(.system(size: 30, weight: .bold))
            VStack(spacing: 8) {
                Group {
                    if viewModel.isAlreadyVerified {
                        Text("이미 인증을 완료한 이메일 주소예요. 인증은 1시간 동안 유지돼요.")
                    } else {
                        Text("방금 입력하신 이메일 주소(\(viewModel.email))로 인증 코드가 담긴 편지를 보냈어요. 편지를 열어서 인증 코드를 확인한 후 입력하면 가입을 시작할게요. ")
                        Text("인증 코드는 보낸 시간부터 3분 동안 사용할 수 있어요.")
                    }
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
    
    private var resendSection: some View {
        @ViewBuilder
        var validationCodeGuideView: some View {
            Group {
                if let remainingAttempts = viewModel.remainingAttemptsForCreationValidationCode, remainingAttempts > 0 {
                    VStack(spacing: 12) {
                        if !viewModel.isLoading {
                            Button(action: viewModel.resendValidationCode) {
                                Text("인증 코드 새로 받기")
                            }
                            .buttonStyle(CapsuleButtonMediumStyle(status: .authSecondary))
                            Text("인증 코드가 만료됐거나, 편지를 못 받으셨거나, 지우셨다면 새 인증 코드를 받아보세요. 오늘 \(remainingAttempts)번 더 받을 수 있어요.")
                        } else {
                            ProgressView()
                            Text("인증 코드를 다시 보내고 있어요...")
                        }
                    }
                } else {
                    Text("인증 코드가 만료됐거나, 편지를 못 받으셨거나, 지우셨다면, 내일 다시 가입을 시도하세요.")
                }
            }
            .font(.system(size: 12, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.gray35)
        }
        
        @ViewBuilder
        var dailyLimitsGuideText: some View {
            if let dailyLimits = viewModel.dailyLimitsForCreationValidationCode {
                Text("인증 코드는 이메일 주소 당 하루에 최대 \(dailyLimits)번까지 만들 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray35)
            } else {
                EmptyView()
            }
        }
        
        return VStack(alignment: .center, spacing: 0) {
            HorizontalDivider()
            VStack(alignment: .center, spacing: 4) {
                validationCodeGuideView
                dailyLimitsGuideText
            }
            .padding(20)
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.5 : 1)
        }
    }
    
    private var validationCodeFieldView: some View {
        FloatingTitleTextField(
            title: "인증 코드",
            placeholder: nil,
            isInvalid: false,
            text: $viewModel.validationCode,
            isFocused: $isValidationCodeFocused,
            isAutocorrectionDisabled: true,
            capitalization: .never,
            keyboardType: .numberPad,
            onSubmit: { viewModel.verifyValidationCode() }
        )
        .padding(.horizontal, 20)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.5 : 1)
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(navigationTitle)
                .opacity(0)
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {}) {
                Text("완료")
                    .fontWeight(.semibold)
                    .tint(Color.accentColor)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
