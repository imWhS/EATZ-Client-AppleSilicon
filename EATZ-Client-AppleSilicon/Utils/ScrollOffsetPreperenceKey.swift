//
//  ScrollOffsetPreperenceKey.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
    
}
