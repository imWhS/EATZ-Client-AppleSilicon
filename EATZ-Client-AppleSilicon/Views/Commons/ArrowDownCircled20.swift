//
//  ArrowDownCircled.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct ArrowDownCircled20: View {
    var body: some View {
        VStack {
            Image("arrow-down-5.6")
                .foregroundStyle(Color.accentColor)
                .offset(y: 1)
        }
        .frame(width: 20, height: 20)
        .background(Color.init(hex: "ECECEC"))
        .cornerRadius(9)
    }
}

#Preview {
    ArrowDownCircled20()
}
