//
//  VerticalDividerView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct VerticalDividerView: View {
    var color: Color = .init("F1F1F1")
    var horizontalPadding: CGFloat = 20
    var width: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width)
            .padding(.vertical, horizontalPadding)
    }
}

#Preview {
    VerticalDividerView()
}
