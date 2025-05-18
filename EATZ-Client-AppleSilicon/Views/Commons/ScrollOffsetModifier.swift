//
//  ScrollOffsetModifier.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct ScrollOffsetModifier: ViewModifier {
//    let coordinateSpace: String
    @Binding var offset: CGPoint

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let x = proxy.frame(in: .global).minX
                let y = proxy.frame(in: .global).minY
//                let x = proxy.frame(in: .named(coordinateSpace)).minX
//                let y = proxy.frame(in: .named(coordinateSpace)).minY
                
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: CGPoint(x: x * -1, y: y * -1))
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}
