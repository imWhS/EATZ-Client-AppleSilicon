//
//  PlannerChecklistBannerTypeB.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/5/26.
//

import SwiftUI

struct PlannerChecklistBannerTypeB: View {
    let planCount: Int?
    let onPresentChecklistTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if hasPlans { contentView }
            else { emptyStateView }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var checklistSubtitleLabel: String {
        guard let count = planCount, 0 < count else { return "플랜" }
        return "총 \(count)개의 플랜 별 요리 현황과 준비물 모아보기"
    }
    
    private var hasPlans: Bool {
        guard let count = planCount else { return true }
        return 0 < count
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                checklistButton
                Text(checklistSubtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(Color.gray35)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: planCount)
            }
            .padding(20)
        }
        .border(color: Color.init(hex: "E2E2E2"), width: 1, radius: 28)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    private var checklistButton: some View {
        Button(action: onPresentChecklistTapped) {
            HStack {
                Text("체크리스트")
                    .font(.system(size: 17, weight: .semibold))
                    .fontWeight(.semibold)
                Image("arrow-right-14")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CapsuleLargeButtonStyle(appearance: .primary))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text("레시피를 플래너에 추가해보세요.")
                .font(Font.system(size: 17, weight: .semibold))
            Text("플래너의 특정 날짜 또는 원하는 기간에 플랜으로 추가한 모든 레시피를 요리하기 위해 필요한 재료와 도구를 체크리스트로 확인할 수 있어요.")
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
        }
        .padding(.horizontal, 20)
    }
}
