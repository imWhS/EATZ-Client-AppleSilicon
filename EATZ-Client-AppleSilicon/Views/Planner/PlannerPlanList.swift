//
//  PlannerPlanList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/7/25.
//

import SwiftUI

struct PlannerPlanList: View {
    @EnvironmentObject var viewModel: PlannerViewModelOld
    
    let date: Date
    let plans: [PlannerPlan]?
    let onAddPlan: (Date) -> Void
    let onPlanAction: (PlannerPlan, PlannerPlanItemAction) -> Void
    
    init(_ date: Date,
         plans: [PlannerPlan]?,
         onAddPlan: @escaping (Date) -> Void,
         onPlanAction: @escaping (PlannerPlan, PlannerPlanItemAction) -> Void) {
        self.date = date
        self.plans = plans
        self.onAddPlan = onAddPlan
        self.onPlanAction = onPlanAction
    }
    
    private let horizontalCommonPadding: CGFloat = 20
    private let itemSpacing: CGFloat = 8
    private let itemsInRow: Int = 2
    
    private var contentViewHeight: CGFloat {
        (UIScreen.main.bounds.width - (horizontalCommonPadding * 2) - itemSpacing) / CGFloat(itemsInRow)
    }
    
    private var detailLabel: String {
        return "+ 버튼을 탭해서, \(date.formattedMonthDay)에 요리할 레시피를 플래너에 추가해보세요."
    }
    
    private var mainContentView: some View {
        Group {
            if let plans = plans, !plans.isEmpty { planListView(plans) }
            else { emptyContentView }
        }
    }
    
    private var emptyContentView: some View {
        PlannerPlanListGuideView(
            title: "요리할 레시피가 없어요.",
            subtitle: detailLabel,
            height: contentViewHeight
        )
        .padding(20)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            mainContentView
            PlannerPlanListFooterView(date: date, itemCount: plans?.count, onAddPlan: onAddPlan)
        }
    }
    
    private func planListView(_ plans: [PlannerPlan]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(plans) { plan in
                    PlannerPlanItem(plan, onAction: onPlanAction)
                        .transition(.opacity)
                }
                PlannerPlanListGuideView(subtitle: detailLabel, height: contentViewHeight)
                    .frame(width: contentViewHeight)
                    .padding(.vertical, 20)
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut(duration: 0.3), value: plans)
    }
}

private struct PlannerPlanListGuideView: View {
    var title: String?
    let subtitle: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.gray35)
            }
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .foregroundStyle(Color.gray20)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .cornerRadius(16)
        .border(color: Color.init(hex: "E2E2E2"), width: 1, radius: 16)
    }
}

private struct PlannerPlanListFooterView: View {
    let date: Date
    let itemCount: Int?
    let onAddPlan: (Date) -> Void
    
    private var itemCountLabel: String {
        if let itemCount = self.itemCount {
            return "\(itemCount)개의 플랜"
        } else {
            return ""
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                topSectionView
                bottomSectionView
            }
            addPlanButton
        }
        .padding(.horizontal, 20)
    }
    
    private var topSectionView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(EatzDateTimeFormatters.weekday.string(from: date))
                .font(.system(size: 17, weight: .semibold))
            
            if Calendar.current.isDateInToday(date) {
                Text("오늘")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            Spacer()
        }
    }
    
    private var bottomSectionView: some View {
        HStack(alignment: .center) {
            Group {
                Text(EatzDateTimeFormatters.monthDayWithUnit.string(from: date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black)
                Text(itemCountLabel)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.gray35)
            
            Spacer()
        }
    }
    
    private var addPlanButton: some View {
        Button(action: { onAddPlan(self.date) }) {
            Image("add-12")
        }
        .buttonStyle(CapsuleMediumButtonStyle(status: .secondary, isIconOnly: true))
    }
}

