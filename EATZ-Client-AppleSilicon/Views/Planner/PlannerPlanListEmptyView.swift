//
//  PlanListEmptyView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/6/25.
//

import SwiftUI

struct PlannerPlanListEmptyView: View {
    private let height: CGFloat = (UIScreen.main.bounds.width - 40 - 8) / 2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 4) {
                Text("추가한 레시피가 없어요.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.gray35)
                Text("+ 버튼을 탭해서 레시피를 추가해보세요.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .cornerRadius(16)
            .border(color: Color.init(hex: "E2E2E2"), width: 1, radius: 16)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    PlannerPlanListEmptyView()
}
