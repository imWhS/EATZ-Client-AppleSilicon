//
//  HorizontalDividerView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct HorizontalDividerView: View {
    var color: Color = .init("F1F1F1")
    var horizontalPadding: CGFloat = 20
    var height: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
    }
}

#Preview {
    HorizontalDividerView()
}
