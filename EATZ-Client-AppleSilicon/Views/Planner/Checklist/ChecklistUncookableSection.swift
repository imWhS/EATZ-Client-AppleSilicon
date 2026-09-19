//
//  ChecklistUncookableSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import SwiftUI

struct ChecklistUncookableSection: View {
    let uncookable: ChecklistCookability
    let isUpdatingPantry: Bool
    let pendingKitchenwareIds: Set<Int64>
    let pendingIngredientIds: Set<Int64>
    let missingIngredientCount: Int
    let missingKitchenwareCount: Int
    let onAddAllRequirements: () -> Void
    let onPlanItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let onKitchenwareItemAction: (Int64, ChecklistKitchenwareAction) -> Void
    let onIngredientItemAction: (Int64, ChecklistIngredientAction) -> Void
    
    @State private var isPurchaseSheetPresented: Bool = false
    
    private var missingKitchenwareLabel: String {
        if missingKitchenwareCount == 0 { return "" }
        else {
            let suffix = missingIngredientCount == 0 ? "" : "와"
            return "도구 \(missingKitchenwareCount)개\(suffix)"
        }
    }

    private var missingIngredientLabel: String {
        if missingIngredientCount == 0 { return "" }
        else {
            let prefix = missingKitchenwareCount == 0 ? "" : " "
            return "\(prefix)재료 \(missingIngredientCount)개"
        }
    }
    
    var body: some View {
        contentView
            .padding(.horizontal, 20)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            header
            ChecklistCookabilityView(
                cookability: uncookable,
                isUpdatingPantry,
                missingKitchenwareCount,
                missingIngredientCount,
                pendingKitchenwareIds,
                pendingIngredientIds,
                onPlanItemAction,
                onKitchenwareItemAction,
                onIngredientItemAction)
            VStack(spacing: 0) {
                VStack (spacing: 0) {
                    HorizontalDivider()
                    Button(action: { isPurchaseSheetPresented = true }) {
                        HStack(spacing: 4) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image("shopping-18")
                                        .foregroundStyle(Color.accentColor)
                                    HStack(spacing: 4) {
                                        Group {
                                            Text("준비물 구입")
                                            DotSeparator(color: Color.accentColor)
                                            Text("쇼핑하기")
                                        }
                                        .foregroundStyle(Color.accentColor)
                                        .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                Text("필요한 도구와 재료를 온라인에서 준비해보세요.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.gray50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Image("external-link-14-light")
                                .foregroundStyle(Color.accentColor)
                        }
                        .padding(16)
                    }
                    .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 14))
                    .padding(4)
                }
                HorizontalDivider()
                VStack(spacing: 0) {
                    Text("이미 위의 재료와 도구를 모두 가지고 있다면, 지금 바로 보관함에 재료와 도구를 추가해보세요.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    Button(action: onAddAllRequirements) {
                        HStack(spacing: 4) {
                            Image("add-circled-22")
                            Text("모두 보관함에 추가")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedButtonStyle(.primary, .large))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .animation(.easeInOut(duration: 0.3), value: [
            uncookable.plans.count,
            missingKitchenwareCount,
            missingIngredientCount
        ])
        .getPurchaseContext($isPurchaseSheetPresented, item: nil)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("requirement-unavailable-62")
                .shadow(color: Color.init(hex: "F2B518").opacity(0.75), radius: 8, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("지금 요리할 수 없는\n\(uncookable.plans.count)개의 플랜")
                        .font(.system(size: 17, weight: .semibold))
                    Text("모든 레시피를 요리하려면\n\(missingKitchenwareLabel)\(missingIngredientLabel)를 더 준비해야 돼요.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
            }
        }
        .padding(20)
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4).foregroundStyle(Color.white) }
    }
}
