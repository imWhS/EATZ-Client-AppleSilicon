//
//  ChecklistView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/6/25.
//

import SwiftUI

struct ChecklistView: View {
    @StateObject private var viewModel: ChecklistViewModel
    @EnvironmentObject private var router: Router
    
    private let titleLabel: String = "체크리스트"
    
    init(dateRange: (startDate: Date, endDate: Date)) {
        _viewModel = StateObject(wrappedValue: ChecklistViewModel(dateRange: dateRange))
    }
    
    var body: some View {
        currentStateView
            .task { viewModel.resetAndLoadAll() }
            .refreshable { await viewModel.refresh() }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: Binding.init(isPresenting: $viewModel.alert),
                presenting: viewModel.alert,
                actions: { $0.actions },
                message: { $0.message })
            .getReportContext(resource: $viewModel.reportResource)
    }
    
    @ViewBuilder
    private var currentStateView: some View {
        Group {
            switch viewModel.viewState {
            case .content:
                if let checklist = viewModel.checklist {
                    ChecklistContentView(
                        viewModel,
                        titleLabel,
                        checklist,
                        viewModel.dateRange,
                        viewModel.handleAddAllRequirementsToPantry)
                } else {
                    ErrorCurtain("체크리스트를 화면에 표시하지 못했어요.") {
                        Task { await viewModel.refresh() }
                    }
                }
            case .initialLoading:
                LoadingCurtain(title: "체크리스트를 만들고 있어요...")
            case .error(let message):
                ErrorCurtain(message) {
                    Task { await viewModel.refresh() }
                }
            }
        }
        .background(Color.backgroundPrimary)
//        .background(Color.yellow)
        .navigationTitle(titleLabel)
        .toolbar {
            titleToolbarItem
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(titleLabel)
                .font(.headline)
                .opacity(viewModel.showNavigationBarTitle ? 1 : 0)
        }
    }
    
}

private struct ChecklistContentView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    let titleLabel: String
    let checklist: Checklist
    let dateRange: (startDate: Date, endDate: Date)
    let onAddAllRequirements: () -> Void
    
    init(_ viewModel: ChecklistViewModel,
         _ titleLabel: String,
         _ checklist: Checklist,
         _ dateRange: (startDate: Date, endDate: Date),
         _ onAddAllItems: @escaping () -> Void) {
        self.viewModel = viewModel
        self.titleLabel = titleLabel
        self.checklist = checklist
        self.dateRange = dateRange
        self.onAddAllRequirements = onAddAllItems
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                scrollTracker
                header
                cookabilitySections
            }
        }
    }
    
    private var cookabilitySections: some View {
        VStack(spacing: 20) {
            if !checklist.uncookable.plans.isEmpty {
                ChecklistUncookableSection(
                    uncookable: checklist.uncookable,
                    missingIngredientCount: checklist.missingIngredientCount,
                    missingKitchenwareCount: checklist.missingKitchenwareCount,
                    onAddAllRequirements: onAddAllRequirements,
                    onPlanItemAction: viewModel.handlePlanItemAction,
                    onKitchenwareItemAction: viewModel.handleKitchenwareItemAction,
                    onIngredientItemAction: viewModel.handleIngredientItemAction)
            }
            
            if !checklist.cookable.plans.isEmpty {
                ChecklistCookableSection(
                    cookable: checklist.cookable,
                    onAddAllRequirements: onAddAllRequirements,
                    onPlanItemAction: viewModel.handlePlanItemAction,
                    onKitchenwareItemAction: viewModel.handleKitchenwareItemAction,
                    onIngredientItemAction: viewModel.handleIngredientItemAction)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            PlannerPeriodIndicator(style: .plain, startDate: dateRange.startDate, endDate: dateRange.endDate)
                .background(Capsule().fill(Color.white))
            VStack(spacing: 4) {
                Text(titleLabel)
                    .font(.system(size: 30, weight: .bold))
                if let planCountLabel = viewModel.planCountLabel {
                    Text(planCountLabel)
                        .font(.system(size: 17, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.init(hex: "A1A1A1"))
                }
            }
            .padding(20)
        }
    }
    
    private var dateRangeView: some View {
        Group {
            if Calendar.current.isDate(dateRange.startDate, inSameDayAs: dateRange.endDate) {
                Text(EatzDateTimeFormatters.monthDayWithUnit.string(from: dateRange.startDate))
            } else {
                HStack(spacing: 4) {
                    Text(EatzDateTimeFormatters.monthDayWithUnit.string(from: dateRange.startDate))
                    Image("planner-calendar-arrow")
                    Text(EatzDateTimeFormatters.monthDayWithUnit.string(from: dateRange.endDate))
                }
            }
        }
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(Color.black)
    }
    
    private var scrollTracker: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named("scroll")).minY
            Color.clear
                .onChange(of: offset) { _, offset in
                    let shouldShow = offset < -50
                    if viewModel.showNavigationBarTitle != shouldShow {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.showNavigationBarTitle = shouldShow
                        }
                    }
                }
        }
        .frame(height: 0)
    }
}

private struct ChecklistUncookableSection: View {
    let uncookable: ChecklistCookability
    let missingIngredientCount: Int
    let missingKitchenwareCount: Int
    let onAddAllRequirements: () -> Void
    let onPlanItemAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    let onKitchenwareItemAction: (Int64, ChecklistKitchenwareItemAction) -> Void
    let onIngredientItemAction: (Int64, ChecklistIngredientItemAction) -> Void
    
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
        VStack(spacing: 0) {
            header
            ChecklistCookabilityView(
                cookability: uncookable,
                missingKitchenwareCount,
                missingIngredientCount,
                onPlanItemAction,
                onKitchenwareItemAction,
                onIngredientItemAction)
            VStack(spacing: 20) {
                HorizontalDivider()
                VStack(spacing: 0) {
                    Text("이미 위의 재료와 도구를 모두 가지고 있다면, 지금 바로 보관함에 재료와 도구를 추가해 보세요.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.init(hex: "C5C5C5"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    Button(action: {
                        // 레시피를 요리하기 위해 필요한(사용자가 보관함에 추가하지 않은) 재료와 도구 모두 사용자 보관함에 일괄 추가합니다.
                        onAddAllRequirements()
                    }) {
                        HStack(spacing: 6) {
                            Image("add-to-pantry-14").foregroundStyle(Color.white)
                            Text("모두 보관함에 추가")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BigRoundedButtonStyle(type: .primary))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 20)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("recipe-ingredients-cookable-unavailable")
                .shadow(color: Color.init(hex: "F2B518").opacity(0.75), radius: 8, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("지금 요리할 수 없는\n\(uncookable.plans.count)개의 플랜")
                        .font(.system(size: 17, weight: .semibold))
                    Text("해당 날짜에 추가한 레시피를 요리하려면\n\(missingKitchenwareLabel)\(missingIngredientLabel)가 더 필요해요.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color(hex: "BCBCBC"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
    }
    
    private func actionButton(image: String, label: String = "", action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(image).padding(4).foregroundStyle(Color.white) }
    }
}

private struct ChecklistCookableSection: View {
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
                        .foregroundStyle(Color(hex: "BCBCBC"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
    }
}

enum ChecklistAlert {
    case confirmAddingAllRequirementsToPantry(
        ingredientsCount: Int, kitchenwaresCount: Int, confirmAction: () -> Void)
    case addedAllRequirementsToPantry(completion: () -> Void)
    case itemUpdateFailed(message: String)
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmAddingAllRequirementsToPantry: return "모두 보관함에 추가"
        case .addedAllRequirementsToPantry: return "모두 보관함에 추가 완료"
        case .itemUpdateFailed: return "재료/도구 상태 변경 실패"
        case .error: return "오류"
        }
    }
    
    var message: some View {
        switch self {
        case .confirmAddingAllRequirementsToPantry(let ingredientsCount, let kitchenwaresCount, _):
            let missingRequirementsLabel = createMissingRequirementsLabel(ingredientsCount, kitchenwaresCount)
            return Text("이 레시피를 요리하기 위해 부족한 \(missingRequirementsLabel)를 회원님의 보관함에 추가할까요?")
        case .addedAllRequirementsToPantry: return Text("모든 재료와 도구를 보관함에 추가했어요.")
        case .itemUpdateFailed(let message): return Text(message)
        case .error(let message): return Text(message)
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmAddingAllRequirementsToPantry(_, _, let confirmAction):
            Button("취소", role: .cancel) {}
            Button("모두 보관함에 추가", action: confirmAction).keyboardShortcut(.defaultAction)
        case .addedAllRequirementsToPantry(let completion): Button("확인", role: .cancel, action: completion)
        case .itemUpdateFailed: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    private func createMissingRequirementsLabel(_ ingredientsCount: Int, _ kitchenwaresCount: Int) -> String {
        var labelItems: [String] = []
        if 0 < kitchenwaresCount { labelItems.append("도구 \(kitchenwaresCount)개") }
        if 0 < ingredientsCount { labelItems.append("재료 \(ingredientsCount)개") }
        
        return labelItems.joined(separator: "와 ")
    }
}
