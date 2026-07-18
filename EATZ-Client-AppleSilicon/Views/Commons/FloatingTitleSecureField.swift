//
//  FloatingTitleSecureField.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/7/25.
//

import SwiftUI

struct FloatingTitleSecureField: View {
    
    let title: String
    let placeholder: String?
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.system(size: 12, weight: .semibold))
                .foregroundStyle(isFocused ? Color.accentColor : Color.init(hex: "CBCBCB"))
                .alignmentGuide(.firstTextBaseline) { _ in 0 }
            SecureField(placeholder ?? "", text: $text)
                .font(Font.system(size: 17, weight: .medium))
                .foregroundStyle(Color.black)
                .focused($isFocused)
                .textContentType(.password)
                .frame(height: 19)
                .onSubmit(onSubmit ?? ({}))
        }
        .frame(height: 68)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.accentColor : Color.init(hex: "EEEEEE"), lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var text = "heextory@icloud.com"
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack {
                FloatingTitleSecureField(
                    title: "이메일을 입력하세요.",
                    placeholder: "이메일 주소",
                    text: $text,
                    isFocused: $isFocused,
                    onSubmit: {}
                )
            }
            .padding(20)
            .background(Color.gray.opacity(0.2))
        }
    }

    return PreviewContainer()
}
