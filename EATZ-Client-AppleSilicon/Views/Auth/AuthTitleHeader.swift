//
//  AuthTitleHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/27/26.
//

import SwiftUI

struct AuthTitleHeader: View {
    let onCancelTapped: () -> Void

    var body: some View {
        HStack {
            Text("계정")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            DismissButton(action: onCancelTapped)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}
