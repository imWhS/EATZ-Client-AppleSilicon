//
//  ArrowCircledDown24.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct ArrowCircledDown24: View {
    var body: some View {
        VStack {
            Image("arrow-down-7")
                .foregroundStyle(Color.accentColor)
                .offset(y: 1)
        }
        .frame(width: 22, height: 22)
        .background(Color.buttonSecondary)
        .cornerRadius(11)
    }
}

#Preview {
    ArrowCircledDown24()
}
