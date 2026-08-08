//
//  CookableFilterToggle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct CookableFilterToggle: View {
    @Binding var isCookableOnly: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            if isEnabled {
                Toggle(isOn: $isCookableOnly) {
                    HStack(spacing: 6) {
                        VerticalDescriptionLabels(
                            "바로 요리 가능",
                            "보관함 속 재료, 도구만으로 바로 요리할 수 있는 레시피만 찾아요.")
                        Spacer()
                    }
                }
                .tint(.accent)
                .padding(20)
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.2)
            } else {
                HStack(spacing: 6) {
                    VerticalDescriptionLabels(
                        "바로 요리 가능",
                        "로그인 또는 가입하면, 바로 요리할 수 있는 레시피만 찾을 수 있어요.")
                    Button("이메일로 시작", action: action)
                        .buttonStyle(CapsuleButtonMediumStyle(status: .authPrimary))
                }
                .padding(20)
            }
        }
        .padding(.horizontal, 20)
    }
}
