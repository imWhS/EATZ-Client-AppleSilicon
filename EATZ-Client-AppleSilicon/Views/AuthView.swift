//
//  AuthView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    let promptMessage: AuthPresentMessageType
    
    @StateObject var viewModel = AuthViewModel()
    
    @State private var goToSignIn = false
    
    @State private var goToSignUp = false
    
    @FocusState private var isEmailFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HeaderView {
                        dismiss()
//                        authManager.loginPrompt = nil
                    }
                    
                    VStack(spacing: 40) {
                        FrontView(loginPrompt: promptMessage)
                        VStack(spacing: 12) {
                            FloatingTitleTextField(
                                title: "이메일 주소",
                                placeholder: nil,
                                text: $viewModel.email,
                                isFocused: $isEmailFocused,
                                autocorrectionDisabled: true,
                                capitalization: .never,
                                keyboardType: .emailAddress
                            )
                            .padding(.horizontal, 20)
                            
                            HStack {
                                Spacer()
                                Button("이메일 주소 찾기") {
                                    print("이메일 주소 찾기")
                                }
                                .buttonStyle(SmallBorderlessButtonStyle())
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    Spacer()
                    .ignoresSafeArea(edges: .bottom)
                }
                VStack {
                    Spacer()
                    if let validationMessage = viewModel.validationMessage {
                        ErrorMessageView(message: validationMessage)
                    }
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: LogInView(dismissAction: dismiss, email: viewModel.email), isActive: $goToSignIn) {
                            EmptyView()
                        }
                        .hidden()
                        authActionButton(title: "로그인", type: .primary) {
                            goToSignIn = true
                        }
                        
                        authActionButton(title: "가입", type: .secondary) {
                            goToSignUp = true
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color.init("F9F9F9"))
//            .navigationDestination(isPresented: $goToSignIn) {
//                LogInView(dismissAction: dismiss, email: viewModel.email)
//            }
            .navigationDestination(isPresented: $goToSignUp) {
                SignUpView(email: viewModel.email)
            }
        }
//        .onChange(of: goToSignIn) { newValue in
//          if newValue { goToSignUp = false }
//        }
//        .onChange(of: goToSignUp) { newValue in
//          if newValue { goToSignIn = false }
//        }
    }
    
    private struct HeaderView: View {
        let onCancel: () -> Void

        var body: some View {
            HStack {
                Text("계정")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                DismissButton {
                    onCancel()
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
        }
    }
    
    private struct FrontView: View {
        let loginPrompt: AuthPresentMessageType
        
        var body: some View {
            VStack(spacing: 16) {
                Text("EATZ")
                    .font(Font.system(size: 52, weight: .heavy))
                    .padding()
                
                Text(loginPrompt.message)
                    .font(Font.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func authActionButton(title: String, type: BigRoundedButtonStyle.ButtonType, action: @escaping () -> Void) -> some View {
        Button(action: {
            if (viewModel.validateEmail()) {
                action()
            }
        }) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BigRoundedButtonStyle(type: type))
    }
}

#Preview {
    AuthView(promptMessage: .logIn)
}
