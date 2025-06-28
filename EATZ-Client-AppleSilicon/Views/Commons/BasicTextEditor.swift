//
//  BasicTextEditor.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/20/25.
//

import SwiftUI

struct BasicTextEditor: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    var placeholder: String? = "탭해서 입력하기"

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused($isFocused)
                .frame(minHeight: 100, maxHeight: 200)
                .background(Color.white)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.accentColor : Color("EEEEEE"), lineWidth: 1)
                )
            if text.isEmpty {
                Text("탭해서 입력하기")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
        }

    }
}

@available(iOS 16.0, *)
struct BasicTextEditor_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var text: String
        @FocusState var isFocused: Bool

        var body: some View {
            BasicTextEditor(text: $text, isFocused: $isFocused)
                .padding()
        }
    }

    static var previews: some View {
        Group {
            PreviewWrapper(text: "")
                .previewDisplayName("Placeholder Visible")
            PreviewWrapper(text: "미리 입력된 텍스트가 표시됩니다.")
                .previewDisplayName("Content Visible")
        }
        .previewLayout(.sizeThatFits)
    }
}
