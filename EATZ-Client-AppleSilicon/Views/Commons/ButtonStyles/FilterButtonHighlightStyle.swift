//
//  FilterButtonHighlightStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct FilterButtonHighlightStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.buttonSecondary.opacity(configuration.isPressed ? 1 : 0)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .cornerRadius(18)
    }
}
