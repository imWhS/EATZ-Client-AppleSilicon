//
//  LogInView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

struct LogInView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = LogInViewModel()
    
    @FocusState private var isFocused: Bool
    
    @State private var isPasswordVisible: Bool = false
    
    let dismissAction: DismissAction
    
    let email: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("비밀 번호")
                .font(.system(size: 26, weight: .bold))
            Text("\(email) 계정으로 로그인하기 위해, 비밀 번호를 입력해주세요.")
                .font(Font.system(size: 14))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            PasswordView(password: $viewModel.password, isFocused: $isFocused, isPasswordVisible: $isPasswordVisible)
            Spacer()
            if let statusMessage = viewModel.statusMessage {
                ErrorMessageView(message: statusMessage)
            }
            Button(action: {
                withAnimation {
                    isPasswordVisible.toggle()
                }
            }) {
                Text(isPasswordVisible ? "비밀 번호 감추기" : "비밀 번호 보기")
                    .fontWeight(.bold)
            }
            .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
        }
        .padding(.vertical, 20)
        .background(Color.init("F9F9F9"))
        .navigationTitle("로그인")
        .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       if viewModel.isLoading {
                           ProgressView()
                       } else {
                           Button("완료") {
                               viewModel.signIn(email: email) {
                                   dismissAction()
                               }
                           }
                           .fontWeight(.semibold)
                       }
                       
                   }
               }
    }
    
    struct PasswordView: View {
        @Binding var password: String
        @FocusState.Binding var isFocused: Bool
        @Binding var isPasswordVisible: Bool
        
        var body: some View {
            ZStack {
                FloatingTitleTextField(title: "비밀 번호", placeholder: nil, text: $password, isFocused: $isFocused)
                    .padding(.horizontal, 20)
                    .opacity(isPasswordVisible ? 1 : 0)
                    .disabled(!isPasswordVisible)
                FloatingTitleSecureField(title: "비밀 번호", placeholder: nil, text: $password, isFocused: $isFocused)
                    .padding(.horizontal, 20)
                    .opacity(isPasswordVisible ? 0 : 1)
                    .disabled(isPasswordVisible)
            }
        }
    }
}

#Preview {
//    LogInView(email: "heextory@icloud.com")
}
