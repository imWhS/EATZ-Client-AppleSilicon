//
//  LogInPasswordField.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/25/26.
//

import SwiftUI

struct LogInPasswordField: View {
    @Binding var password: String
    @FocusState.Binding var isFocused: Bool
    @Binding var isPasswordVisible: Bool
    
    let onLogIn: () -> Void
    
    var body: some View {
        ZStack {
            FloatingLabeledTextField(
                floatingLabel: "암호",
                placeholder: nil,
                isInvalid: false,
                text: $password,
                isFocused: $isFocused)
            .padding(.horizontal, 20)
            .opacity(isPasswordVisible ? 1 : 0)
            .disabled(!isPasswordVisible)
            .onSubmit(onLogIn)
            FloatingLabeledSecureField(
                floatingLabel: "암호",
                placeholder: nil,
                text: $password,
                isFocused: $isFocused)
            .padding(.horizontal, 20)
            .opacity(isPasswordVisible ? 0 : 1)
            .disabled(isPasswordVisible)
            .onSubmit(onLogIn)
        }
    }
}
