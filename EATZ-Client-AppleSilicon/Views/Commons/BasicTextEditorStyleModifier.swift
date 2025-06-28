//
//  BasicTextEditorStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/20/25.
//

import SwiftUI

struct BasicTextEditorStyleModifier: ViewModifier {
    @Binding var text: String
    var placeholder: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                content
                    .frame(minHeight: 100, maxHeight: 200)
                    .background(Color.white)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("EEEEEE"), lineWidth: 1)
                    )
            }
    }
}
