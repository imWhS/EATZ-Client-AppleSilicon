//
//  View+Extensions.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/7/25.
//

import SwiftUI

extension View {
    func trackOffset(into binding: Binding<CGPoint>) -> some View {
        modifier(ScrollOffsetModifier(offset: binding))
    }
}

extension View {
    @ViewBuilder
    func onReadSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        customBackground {
            GeometryReader { geometryProxy in
                Color
                    .clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }

    @ViewBuilder
    func customBackground<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        background(alignment: alignment, content: content)
    }
}


extension View {
    func border(color: Color = .gray.opacity(0.3),
                width: CGFloat = 1,
                radius: CGFloat = 24) -> some View {
        modifier(BorderModifier(color: color, width: width, radius: radius))
    }
}
