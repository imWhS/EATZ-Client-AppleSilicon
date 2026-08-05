//
//  AuthSignUpGuideView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import SwiftUI

struct AuthSignUpGuideView: View {
    let guides: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                ForEach(guides, id: \.self) { guide in
                    HStack(alignment: .top) {
                        Image("info-14")
                        Text(guide)
                    }
                }
            }
            .font(Font.system(size: 12, weight: .medium))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.gray35)
            .lineLimit(nil)
            .padding(.horizontal, 20)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AuthSignUpGuideView(guides: ["테스트 가이드 1", "내용이 아주 아주 아주 조금 조금 더 더 아주 아주 아주 조금 조금 더 더 긴 테스트 가이드 2"])
}
