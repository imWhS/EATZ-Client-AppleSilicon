//
//  DotSeparatorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct DotSeparator: View {
    let diameter: CGFloat
    
    init(diameter: CGFloat = 2.5) {
        self.diameter = diameter
    }
    
    var body: some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .foregroundStyle(Color.gray15)
    }
}

#Preview {
    DotSeparator()
}
