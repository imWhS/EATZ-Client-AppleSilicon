//
//  SizePreferenceKey.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/20/25.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
    
}
