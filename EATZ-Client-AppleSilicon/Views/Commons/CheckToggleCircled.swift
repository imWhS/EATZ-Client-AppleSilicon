//
//  ArrowDownCircled.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct CheckToggleCircled: View {
    let isToggled: Bool
    
    var body: some View {
        VStack {
            Image("check-12")
        }
        .frame(width: 26, height: 26)
        .foregroundStyle(isToggled ? Color.white : Color.init(hex: "76BD2F"))
        .background(Color.init(hex: isToggled ? "76BD2F" : "ECECEC"))
        .cornerRadius(13)
    }
}

#Preview {
    HStack {
        VStack(spacing: 12) {
            CheckToggleCircled(isToggled: true)
            Text("토글이 켜진 상태")
                .font(.system(size: 12, weight: .semibold))
        }
        VStack(spacing: 12) {
            CheckToggleCircled(isToggled: false)
            Text("토글이 꺼진 상태")
                .font(.system(size: 12, weight: .semibold))
        }
    }
}
