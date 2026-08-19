//
//  CookableKeywordFieldBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/19/26.
//

import SwiftUI

struct CookableKeywordFieldBar: View {
    @Binding var keyword: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        Button(action: {
            isFocused = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    TextField("키워드", text: $keyword)
                        .font(.system(size: 17, weight: .semibold))
                        .focused($isFocused)
                        .allowsHitTesting(isFocused) // 포커스가 없을 때에는 터치 이벤트를 무시해서, 상위 Button이 대신 받도록 처리합니다.
                    
                    Text("레시피 제목, 내용")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.init(hex: "C5C5C7"))
                }
                Spacer()
                if (isFocused && !keyword.isEmpty) {
                    Remove14Button {
                        keyword = ""
                    }
                    .padding(.vertical, 6)
                    .padding(.leading, 6)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .onTapGesture { isFocused = true }
        }
        .buttonStyle(CookableKeywordFieldBarButtonStyle())
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

private struct CookableKeywordFieldBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .cornerRadius(18)
                    .shadow(
                        color: .black.opacity(configuration.isPressed ? 0.0275 : 0.125),
                        radius: configuration.isPressed ? 6 : 12,
                        y: configuration.isPressed ? 4 : 6
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
