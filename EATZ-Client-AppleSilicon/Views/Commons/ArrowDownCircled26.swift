//
//  ArrowDownCircled.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct ArrowDownCircled26: View {
    var body: some View {
        VStack {
            Image("arrow-down-8")
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: 26, height: 26)
        .background(Color.init(hex: "ECECEC"))
        .cornerRadius(13)
    }
}
