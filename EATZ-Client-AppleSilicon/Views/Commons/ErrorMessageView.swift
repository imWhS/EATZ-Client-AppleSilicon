//
//  ErrorMessageView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/11/25.
//

import SwiftUI

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image("info")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
    }
}

#Preview {
    ErrorMessageView(message: "올바르지 않은 데이터입니다.")
}
