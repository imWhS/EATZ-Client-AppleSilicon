//
//  AuthView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI
import Combine

/// 로그인 및 가입 등 사용자 전체 인증 흐름을 진행하기 위해 필요한 뷰입니다.
///
/// - GlobalPresenter에 의해 화면에 present 되거나 dismiss 되어질 수 있습니다.
/// - 로그인과 가입 흐름 각각은 하나의 논리적인 단위로 취급되어야 합니다.
///   그래서 로그인을 담당하는 LogInView, 가입을 담당하는 SignUpView를 하위 뷰로 둡니다.
struct AuthView: View {
    // MARK: - StateObject 프로퍼터
    
    @StateObject private var viewModel: AuthViewModel
    
    // MARK: - State 프로퍼티
    
    @State private var pushToSignIn = false
    @State private var pushToSignUp = false
    @State private var isKeyboardVisible = false
    @FocusState private var isEmailFocused: Bool
    
    /// AuthView가 화면에 present 되어지는 이유를 나타내는 컨텍스트입니다.
    private let context: AuthContext
    
    /// 로그인 성공 시 호출해야 할 클로저입니다.
    private let onLogInSuccess: (String, CurrentUser) -> Void
    
    /// 로그인 취소(dismiss 액션 실행) 시 호출해야 할 클로저입니다.
    private let onDismiss: () -> Void
    
    private var legalNoticeLabel: String {
        return
            "이메일 주소로 가입한 계정에 로그인합니다. 이메일 주소로 가입한 계정이 없으면 가입을 진행합니다. " +
            "또한, 시작함으로써 **[이용 약관 및 정책](\(EatzLinks.termsOfServiceString))**, " +
            "그리고 [개인 정보 처리 방침](\(EatzLinks.privacyPolicyString))에 동의하는 것으로 간주합니다."
    }
    
    init(context: AuthContext, onLogInSuccess: @escaping (String, CurrentUser) -> Void, onDismiss: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: AuthViewModel(onLogInSuccess: onLogInSuccess))
        self.context = context
        self.onLogInSuccess = onLogInSuccess
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            contentView
                .navigationTitle("계정")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AuthViewModel.AuthNavigationPath.self) { path in
                    Group {
                        switch path {
                        case .logIn: LogInView()
                        case .signUpEmailVerification: SignUpEmailVerificationView()
                        case .signUpSetPassword: SignUpSetPasswordView()
                        case .signUpCreateUsername: SignUpCreateUsernameView()
                        }
                    }
                    .environmentObject(viewModel)
                }
        }
        .onReceive(Publishers.keyboardHeight) { height in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = height > 0
            }
        }
    }
    
    private var contentView: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                contextView
                legalNoticeView
            }
            .alert(item: $viewModel.alert) { $0.alert }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
            AuthTitleHeader(onCancelTapped: onDismiss)
        }
        .background(Color.white)
        .onTapGesture {
            isEmailFocused = false
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    FloatingLabeledTextField(
                        floatingLabel: "이메일 주소",
                        placeholder: nil,
                        isInvalid: false,
                        text: $viewModel.email,
                        isFocused: $isEmailFocused,
                        isAutocorrectionDisabled: true,
                        capitalization: .never,
                        keyboardType: .emailAddress,
                        onSubmit: viewModel.validateEmail
                    )
                    .padding(.horizontal, 20)
                    authActionButton(title: "시작", action: viewModel.validateEmail)
                }
            }
            .padding(.vertical, 20)
            .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
        }
    }
    
    private var contextView: some View {
        VStack(spacing: 30) {
            Spacer()
            AuthFrontView(loginPrompt: context, showMessages: !isKeyboardVisible)
            if !isKeyboardVisible { contextMessageView }
            Spacer()
        }
    }
    
    private var contextMessageView: some View {
        VStack(spacing: 8) {
            Text(context.mainMessage)
                .font(Font.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(context.subMessage)
                .font(Font.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .transition(.opacity)
    }
    
    private var legalNoticeView: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            Text(LocalizedStringKey(legalNoticeLabel))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray15)
                .tint(Color.accent)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(20)
        }
    }
    
    private func authActionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .fontWeight(.semibold)
                Image("arrow-right-14")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundedButtonStyle(.authPrimary, .large))
        .padding(.horizontal, 20)
    }
}

private struct AuthFrontView: View {
    let loginPrompt: AuthContext
    let showMessages: Bool
    
    var body: some View {
        Image("eatz-logo")
            .resizable()
            .scaledToFit()
            .frame(height: 52)
    }
}

/// AuthView를 띄울 때 메시지를 함께 전달하기 위해 사용합니다.
enum AuthContext: Identifiable {
    case logIn
    case authRequiredAction
    case sessionExpired

    var id: String {
        switch self {
        case .logIn:
            return "logIn"
        case .authRequiredAction:
            return "authRequiredAction"
        case .sessionExpired:
            return "sessionExpired"
        }
    }
    /// 로그인 시트에 보여줄 안내 메인 메시지
    var mainMessage: String {
        switch self {
        case .logIn:
            return "이메일로 시작해볼까요?"
        case .authRequiredAction:
            return "계속 하려면 계정이 필요해요.\n이메일로 시작해볼까요?"
        case .sessionExpired:
            return "로그아웃 상태로 전환됐어요.\n작업을 계속 하려면 다시 로그인해주세요."
        }
    }
    /// 로그인 시트에 보여줄 안내 서브 메시지
    var subMessage: String {
        switch self {
        case .logIn, .authRequiredAction:
            return "로그인 할 계정 또는 가입에 사용할 이메일 주소를 입력하세요."
        case .sessionExpired:
            return "다른 계정으로 로그인하거나,\n새 계정을 만들어서 로그인하면 직전 작업이 종료될 수 있어요."
        }
    }
}
