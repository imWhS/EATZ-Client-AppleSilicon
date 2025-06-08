//
//  PressedButtonBackgroundStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct PressedButtonBackgroundStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PressedBackgroundView(isPressed: configuration.isPressed) {
            configuration.label
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
        }
    }

    struct PressedBackgroundView<Label: View>: View {
        let isPressed: Bool
        let label: () -> Label

        @State private var showOverlay = false

        var body: some View {
            label()
                .background(
                    Color.black
                        .opacity(showOverlay ? 0.05 : 0)
                        .animation(showOverlay ? .easeIn(duration: 0.075) : .easeOut(duration: 0.3), value: showOverlay)
                )
                .cornerRadius(12)
                .onChange(of: isPressed) { newValue in
                    showOverlay = newValue
                }
        }
    }
}
