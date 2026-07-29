//
//  ArrowRightCircled20.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct ArrowRightCircled20: View {
    var body: some View {
        VStack {
            Image("arrow-right-6.8")
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: 20, height: 20)
        .background(Color.buttonSecondary)
        .cornerRadius(9)
    }
}
