//
//  VerticalDividerView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct VerticalDivider: View {
    var color: Color = .black.opacity(0.075)
    var padding: CGFloat = 20
    var width: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width)
            .padding(.vertical, padding)
    }
}

#Preview {
    VerticalDivider()
}
