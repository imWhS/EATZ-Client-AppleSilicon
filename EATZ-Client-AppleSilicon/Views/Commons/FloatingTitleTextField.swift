//
//  FloatingTitleTextField.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/7/25.
//

import SwiftUI

struct FloatingTitleTextField: View {
    
    let title: String
    
    let placeholder: String?
    
    @Binding var text: String
    
    @FocusState.Binding var isFocused: Bool
    
    var autocorrectionDisabled: Bool = true
    
    var capitalization: TextInputAutocapitalization = .never
    
    var keyboardType: UIKeyboardType = .default
    
    var textContentType: UITextContentType?
    
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.system(size: 11, weight: .semibold))
                .foregroundColor(isFocused ? Color.accentColor : Color.init("CBCBCB"))
            TextField(placeholder ?? "", text: $text)
                .font(Font.system(size: 16, weight: .medium))
                .focused($isFocused)
                .autocorrectionDisabled(autocorrectionDisabled)
                .textInputAutocapitalization(capitalization)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .frame(height: 19)
                .onSubmit(onSubmit ?? ({}))
        }
        .frame(height: 68)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.accentColor : Color.init("EEEEEE"), lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true
        }
        .frame(height: 68)
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var text = "heextory@icloud.com"
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack {
                FloatingTitleTextField(
                    title: "이메일 주소",
                    placeholder: "이메일을 입력하세요",
                    text: $text,
                    isFocused: $isFocused // 외부에서 제어
                )
            }
            .padding(20)
            .background(Color.gray.opacity(0.2))
        }
    }

    return PreviewContainer()
}
