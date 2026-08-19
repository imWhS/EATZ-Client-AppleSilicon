//
//  PlannerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/2/25.
//

import SwiftUI

struct PlannerViewOld: View {
    @StateObject private var viewModel = PlannerViewModelOld()
    @EnvironmentObject private var router: Router

    var body: some View {
        NavigationStack(path: $router.path) {
            viewStateContent
                .toolbar(.hidden, for: .navigationBar)
                .navigationTitle(MainTabItems.planner.title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ViewRoute.self) { route in
                    DestinationView(route)
                }
        }
        .task(id: viewModel.currentUser) { viewModel.prepareDataIfNeeded() }
        .onChange(of: router.path) { _, path in
            if path.isEmpty { viewModel.prepareDataIfNeeded() }
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .sheet(item: $viewModel.sheet, content: buildSheet)
    }
    
    @ViewBuilder
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain()
            case .loaded: mainContent
                    .environmentObject(viewModel)
            case .error(let message): ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded)
            case .unauthorized: PlannerUnauthorizedView(onLogIn: viewModel.requireAuthView)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            PlannerHeader(
                dateRange: viewModel.dateRange,
                isDisabled: (viewModel.viewState == .unauthorized),
                onShowCalendar: { viewModel.sheet = .calendar })
        }
        .background(Color.backgroundPrimary)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                PlannerChecklistBannerTypeA(
                    planCount: viewModel.planCountInDateRange,
                    onPresentChecklist: {
                        router.push(.checklist(
                            startDate: viewModel.dateRange.startDate,
                            endDate: viewModel.dateRange.endDate
                        ))
                    })
                planListSection
            }
        }
        .refreshable { await viewModel.refresh() }
    }
    
    private var planListSection: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.displayedDates, id: \.self) { date in
                PlannerPlanList(
                    date,
                    plans: viewModel.plansByDate[date.formattedStandard],
                    onAddPlanTapped: { date in viewModel.sheet = .plannerRecipePicker(date: date) },
                    onPlanAction: viewModel.handlePlanItemAction)
            }
        }
    }
    
    @ViewBuilder
    private func buildSheet(for type: PlannerSheetOld) -> some View {
        switch type {
        case .plannerDatePicker(let recipeId):
            PlannerDatePicker(for: recipeId) {
                Task { await viewModel.refresh() }
            }
        case .plannerRecipePicker(let date):
            PlannerRecipePicker(date) {
                Task { await viewModel.refresh() }
            }
        case .calendar:
            CalendarPicker(mode: .range) { dateSelection in
                Task { await viewModel.handleDateSelection(for: dateSelection)}
            }
        }
    }
}

enum PlannerSheetOld: Identifiable {
    case plannerDatePicker(recipeId: Int64)
    case plannerRecipePicker(date: Date)
    case calendar
    
    var id: String {
        switch self {
        case .plannerDatePicker(let recipeId): return "plannerDatePicker-\(recipeId)"
        case .plannerRecipePicker(let date): return "plannerRecipePicker-\(date)"
        case .calendar: return "calendar"
        }
    }
}

enum PlannerAlertOld: Identifiable {
    case sessionExpired
    case error(titls: String? = nil, message: String)
    
    var id: String {
        switch self {
        case .sessionExpired: return "sessionExpired"
        case .error(let title, let message): return "\(title ?? "")-\(message)"
        }
    }
    
    var title: String {
        switch self {
        case .sessionExpired: "세션 만료"
        case .error: "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .sessionExpired: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .sessionExpired: Text("로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(_, let message): Text(message)
        }
    }
}

