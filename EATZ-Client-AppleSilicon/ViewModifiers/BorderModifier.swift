//
//  BorderModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct BorderModifier: ViewModifier {
    var color: Color = .gray.opacity(0.3)
    var width: CGFloat = 1
    var radius: CGFloat = 24
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: width)
                )
            .cornerRadius(radius)
    }
}
