//
//  FloatingTitleTextFieldTest.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/7/25.
//

import SwiftUI

struct FloatingTitleTextField: View {
    let title: String?
    let placeholder: String?
    let isInvalid: Bool
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    var isAutocorrectionDisabled: Bool = true
    var capitalization: TextInputAutocapitalization = .never
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)? = nil
    
    private var titleColor: Color {
        if isInvalid {
            return .orange
        } else if isFocused {
            return .accentColor
        } else {
            return .gray25
        }
    }
    
    private var borderColor: Color {
        if isInvalid {
            return .orange
        } else if isFocused {
            return .accentColor
        } else {
            return .gray8
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .id("title")
                        .font(Font.system(size: 12, weight: .semibold))
                        .foregroundStyle(titleColor)
                        .drawingGroup()
                }
                TextField(placeholder ?? "", text: $text)
                    .font(Font.system(size: 17, weight: .medium))
                    .focused($isFocused)
                    .autocorrectionDisabled(isAutocorrectionDisabled)
                    .textInputAutocapitalization(capitalization)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .frame(height: 19)
                    .submitLabel(submitLabel)
                    .onSubmit(onSubmit ?? ({}))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .onTapGesture {
                isFocused = true
            }
            .frame(minHeight: 68)
        }
    }
}
