//
//  AuthSignUpGuideView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import SwiftUI

struct GuideView: View {
    let guides: [String]
    let horizontalPadding: CGFloat
    
    init(guides: [String], horizontalPadding: CGFloat = 20) {
        self.guides = guides
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                ForEach(guides, id: \.self) { guide in
                    HStack(alignment: .top, spacing: 4) {
                        Image("info-14")
                        Text(guide)
                            .font(Font.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .foregroundStyle(Color.gray35)
            .padding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    GuideView(guides: ["테스트 가이드 1", "내용이 아주 아주 아주 조금 조금 더 더 아주 아주 아주 조금 조금 더 더 긴 테스트 가이드 2"])
}
