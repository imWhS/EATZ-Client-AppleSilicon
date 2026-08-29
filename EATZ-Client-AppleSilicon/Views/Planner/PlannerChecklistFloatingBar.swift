//
//  PlannerChecklistFloatingBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/5/26.
//

import SwiftUI

struct PlannerChecklistFloatingBar: View {
    let planCount: Int?
    let onPresentChecklistTapped: () -> Void
    
    let isCompactMode: Bool
    
    var body: some View {
        contentView
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var checklistSubtitleLabel: String {
        guard let count = planCount, 0 < count else { return "플랜" }
        return "총 \(count)개의 플랜 별 요리 현황과 준비물을 확인해보세요."
    }
    
    private var hasPlans: Bool {
        guard let count = planCount else { return true }
        return 0 < count
    }
    
    @ViewBuilder
    private var contentView: some View {
        if hasPlans {
            VStack(spacing: 20) {
                checklistGuideView
            }
            .padding(isCompactMode ? 6 : 16)
            .background(Color.white)
            .cornerRadius(isCompactMode ? 19 : 26)
            .shadow(
                color: .black.opacity(0.125),
                radius: 12,
                y: 6
            )
            .animation(.snappy(duration: 0.3), value: isCompactMode)
        } else { EmptyView() }
    }
    
    private var checklistGuideView: some View {
        VStack(spacing: 8) {
            checklistButton
            if !isCompactMode {
                Text(checklistSubtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(Color.gray35)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: planCount)
            }
        }
    }
    
    private var checklistButton: some View {
        Button(action: onPresentChecklistTapped) {
            HStack {
                Text("체크리스트")
                    .font(.system(size: 17, weight: .semibold))
                    .fontWeight(.semibold)
                Image("arrow-right-14")
            }
            .frame(maxWidth: isCompactMode ? nil : .infinity)
        }
        .buttonStyle(RoundedButtonStyle(.primary, .large))
    }
}
