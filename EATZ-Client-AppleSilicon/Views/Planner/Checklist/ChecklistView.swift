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
    
    private let navigationTitleLabel: String = "체크리스트"
    
    init(dateRange: (startDate: Date, endDate: Date)) {
        self._viewModel = StateObject(wrappedValue: ChecklistViewModel(dateRange))
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
                        navigationTitleLabel,
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
        .navigationTitle(navigationTitleLabel)
        .toolbar {
            titleToolbarItem
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(navigationTitleLabel)
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
                    isUpdatingPantry: viewModel.isUpdatingPantry,
                    pendingKitchenwareIds: viewModel.pendingKitchenwareIds,
                    pendingIngredientIds: viewModel.pendingIngredientIds,
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
                    isUpdatingPantry: viewModel.isUpdatingPantry,
                    pendingKitchenwareIds: viewModel.pendingKitchenwareIds,
                    pendingIngredientIds: viewModel.pendingIngredientIds,
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
                        .foregroundStyle(Color.gray35)
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
