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
        VStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.gray35)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("잠시만 기다려주세요...")
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.gray35)
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
