//
//  PlannerChecklistBannerTypeA.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/5/26.
//

import SwiftUI

struct PlannerChecklistBannerTypeA: View {
    let planCount: Int?
    let onPresentChecklist: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if hasPlans { descriptionsView }
            else { emptyStateView }
            HorizontalDivider()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var recipeCountLabel: String {
        guard let count = planCount, 0 < count else { return "플랜" }
        return "\(count)개의 플랜"
    }
    
    private var checklistIconView: some View {
        VStack {
            Image("checklist-button-arrow")
                .foregroundStyle(Color.white)
        }
        .frame(width: 42, height: 42)
        .background(Color.accentColor)
        .cornerRadius(21)
    }
    
    private var hasPlans: Bool {
        guard let count = planCount else { return true }
        return 0 < count
    }
    
    private var descriptionsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipeCountLabel)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
                Text("레시피를 요리하기 위해 필요한 항목 확인하기")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            Spacer()
            checklistButton
        }
        .padding(.horizontal, 20)
    }
    
    private var checklistButton: some View {
        Button(action: onPresentChecklist) {
            HStack(spacing: 8) {
                Text("체크리스트")
                    .font(.system(size: 17, weight: .semibold))
                checklistIconView
            }
        }
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
