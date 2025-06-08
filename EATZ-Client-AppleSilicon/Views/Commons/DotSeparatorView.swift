//
//  DotSeparatorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct DotSeparatorView: View {
    var body: some View {
        Circle()
            .frame(width: 2, height: 2)
            .foregroundStyle(Color.init("D9D9D9"))
    }
}

#Preview {
    DotSeparatorView()
}
