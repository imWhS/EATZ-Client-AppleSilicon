//
//  PlannerUnauthorizedView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/5/26.
//

import SwiftUI

struct PlannerUnauthorizedView: View {
    let onLogIn: () -> Void
    
    var body: some View {
        VStack {
            descriptionSection
            bottomActionSection
        }
    }
    
    private var descriptionSection: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("플래너")
                    .font(.system(size: 30, weight: .bold))
                Text("요리하고 싶은 레시피를 플래너의 원하는 날짜에 추가할 수 있어요. 플래너에 추가한 레시피를 요리하기 위해 필요한 재료와 도구를 체크리스트로 정리해드려요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            .padding(20)
            Spacer()
        }
    }
    
    private var bottomActionSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                Button(action: onLogIn) {
                    Text("이메일로 시작").frame(maxWidth: .infinity)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
                Text("로그인 또는 가입 후 계속 진행할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            .padding(20)
        }
    }
}
