//
//  LoadingCurtain.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/7/25.
//

import SwiftUI

struct LoadingCurtain: View {
    let title: String
    
    init(title: String = "불러오고 있어요...") {
        self.title = title
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.init(hex: "8B8B8B"))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("잠시만 기다려주세요...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.init(hex: "A1A1A1"))
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingCurtain()
}
