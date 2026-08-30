//
//  ChecklistCookableSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import SwiftUI

struct ChecklistCookableSection: View {
    let cookable: ChecklistCookability
    let isUpdatingPantry: Bool
    let pendingKitchenwareIds: Set<Int64>
    let pendingIngredientIds: Set<Int64>
    let onAddAllRequirements: () -> Void
    let onPlanItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let onKitchenwareItemAction: (Int64, ChecklistKitchenwareAction) -> Void
    let onIngredientItemAction: (Int64, ChecklistIngredientAction) -> Void
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            header
            ChecklistCookabilityView(
                cookability: cookable,
                isUpdatingPantry,
                pendingKitchenwareIds,
                pendingIngredientIds,
                onPlanItemAction,
                onKitchenwareItemAction,
                onIngredientItemAction)
        }
        .padding(.bottom, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("requirement-unavailable-62")
                .shadow(color: Color.init(hex: "76BD2F").opacity(0.75), radius: 8, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("지금 바로 요리할 수 있는\n\(cookable.plans.count)개의 플랜")
                        .font(.system(size: 17, weight: .semibold))
                    Text("요리하기 위해 필요한 도구와 재료가\n모두 보관함에 있어요.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
    }
}
