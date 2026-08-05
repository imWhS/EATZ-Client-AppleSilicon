//
//  CheckCircledToggle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct CheckCircledToggle: View {
    let isToggled: Bool
    
    var body: some View {
        VStack {
            Image("check-12")
        }
        .frame(width: 26, height: 26)
        .foregroundStyle(isToggled ? Color.white : Color.init(hex: "76BD2F"))
        .background(isToggled ? Color.init(hex:"76BD2F") : Color.gray8)
        .cornerRadius(13)
    }
}

#Preview {
    HStack {
        VStack(spacing: 12) {
            CheckCircledToggle(isToggled: true)
            Text("토글이 켜진 상태")
                .font(.system(size: 12, weight: .semibold))
        }
        VStack(spacing: 12) {
            CheckCircledToggle(isToggled: false)
            Text("토글이 꺼진 상태")
                .font(.system(size: 12, weight: .semibold))
        }
    }
}
