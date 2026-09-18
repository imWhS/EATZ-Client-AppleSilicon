//
//  DotSeparatorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct DotSeparator: View {
    let diameter: CGFloat
    let color: Color
    
    init(diameter: CGFloat = 2.5, color: Color = .gray15) {
        self.diameter = diameter
        self.color = color
    }
    
    var body: some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .foregroundStyle(color)
    }
}

#Preview {
    DotSeparator()
}
