//
//  PlannerHeaderDateViewButtonStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/26.
//

import SwiftUI

struct PlannerHeaderDateViewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.background(
            Capsule()
                .fill(Color.white)
                .shadow(
                    color: .black.opacity(configuration.isPressed ? 0.0275 : 0.125),
                    radius: configuration.isPressed ? 6 : 12,
                    y: configuration.isPressed ? 4 : 6
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: configuration.isPressed)
            
        )
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
