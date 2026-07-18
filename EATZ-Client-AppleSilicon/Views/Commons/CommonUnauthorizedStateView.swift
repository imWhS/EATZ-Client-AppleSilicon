//
//  CommonGuestStateView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/7/25.
//

import SwiftUI

struct CommonUnauthorizedStateView: View {
    var body: some View {
        Curtain(
            title: "로그인되지 않은 상태입니다.",
            description: "로그인 후 계속할 수 있어요."
        )
    }
}
