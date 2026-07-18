//
//  DotSeparatorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct DotSeparatorView: View {
    let diameter: CGFloat
    
    init(diameter: CGFloat = 2.5) {
        self.diameter = diameter
    }
    
    var body: some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .foregroundStyle(Color.init(hex: "D9D9D9"))
    }
}

#Preview {
    DotSeparatorView()
}
