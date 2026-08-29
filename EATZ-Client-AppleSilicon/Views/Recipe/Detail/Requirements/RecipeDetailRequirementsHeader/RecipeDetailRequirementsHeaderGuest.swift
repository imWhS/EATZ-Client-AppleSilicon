//
//  RecipeDetailRequirementsHeaderGuest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsHeaderGuest: View {
    let onAuth: () -> Void
    
    var body: some View {
        Group {
            contentView
        }
        .padding(.horizontal, 20)
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            Group {
                descriptionsSection
                signWithEmailButton
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.init(hex: "EAF1EC"))
        .cornerRadius(24)
    }
    
    private var descriptionsSection: some View {
        VStack(spacing: 12) {
            Image("handshake")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .foregroundStyle(Color.init(hex: "D1E7D7"))
            VStack(spacing: 12) {
                Text("이메일로 로그인 또는 가입해보세요.")
                    .font(.system(size: 17, weight: .semibold))
                    .multilineTextAlignment(.center)
                Text("이 레시피를 지금 바로 요리할 수 있는지 혹은, 요리하기 위해 필요한 준비물이 무엇인지 확인할 수 있어요.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "93A197"))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var signWithEmailButton: some View {
        Button("이메일로 시작", action: onAuth)
            .buttonStyle(RoundedButtonStyle(.authPrimary, .medium))
    }
}
