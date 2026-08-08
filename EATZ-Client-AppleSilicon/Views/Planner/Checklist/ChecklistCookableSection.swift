//
//  ChecklistCookableSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import SwiftUI

struct ChecklistCookableSection: View {
    let cookable: ChecklistCookability
    let onAddAllRequirements: () -> Void
    let onPlanItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let onKitchenwareItemAction: (Int64, ChecklistKitchenwareItemAction) -> Void
    let onIngredientItemAction: (Int64, ChecklistIngredientItemAction) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            header
            ChecklistCookabilityView(
                cookability: cookable, onPlanItemAction, onKitchenwareItemAction, onIngredientItemAction)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 20)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("recipe-ingredients-cookable-available")
                .shadow(color: Color.init(hex: "76BD2F").opacity(0.75), radius: 8, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("지금 바로 요리할 수 있는\n\(cookable.plans.count)개의 플랜")
                        .font(.system(size: 17, weight: .semibold))
                    Text("요리하기 위해 필요한 모든 도구와 재료가\n보관함에 추가되어 있어요.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
    }
}
