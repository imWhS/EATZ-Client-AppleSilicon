//
//  PlannerMemberView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct PlannerMemberView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: PlannerMemberViewModel
    
    init(_ authManager: AuthManager) {
        self._viewModel = StateObject(wrappedValue: PlannerMemberViewModel(authManager))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                switch viewModel.state {
                case .loading: LoadingCurtain(title: "회원님의 플래너 정보를 불러오고 있어요...").transition(.opacity)
                case .content: contentView.transition(.opacity)
                case .error(let message): ErrorCurtain(message, onRetryTapped: viewModel.prepareDataIfNeeded).transition(.opacity)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                PlannerHeader(
                    dateRange: viewModel.dateRange,
                    onShowCalendar: { viewModel.sheet = .calendar })
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.state)
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle(MainTabItems.planner.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
        }
        .task { viewModel.prepareDataIfNeeded() }
        .onChange(of: router.path) { _, path in
            if path.isEmpty { viewModel.prepareDataIfNeeded() }
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .sheet(
            item: $viewModel.sheet,
            onDismiss: {
                DispatchQueue.main.async {
                    self.viewModel.prepareDataIfNeeded()
                }
            },
            content: buildSheet)
        .getReportContext(resource: $viewModel.reportResource)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                PlannerChecklistBannerTypeB(
                    planCount: viewModel.planCountInDateRange,
                    onPresentChecklistTapped: {
                        router.push(.checklist(
                            startDate: viewModel.dateRange.startDate,
                            endDate: viewModel.dateRange.endDate
                        ))
                    })
                planListSection
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.planCountInDateRange)
        }
        .background(Color.backgroundPrimary)
        .refreshable { await viewModel.refresh() }
    }
    
    private var planListSection: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.displayedDates, id: \.self) { displayedDate in
                PlannerPlanList(
                    displayedDate,
                    plans: viewModel.plansByDate[displayedDate.formattedStandard],
                    onAddPlanTapped: { date in viewModel.sheet = .plannerRecipePicker(date: date) },
                    onPlanAction: viewModel.handlePlanItemAction)
            }
        }
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func buildSheet(for type: PlannerMemberSheet) -> some View {
        switch type {
        case .plannerDatePicker(let recipeId): PlannerDatePicker(for: recipeId)
        case .plannerRecipePicker(let date): PlannerRecipePicker(date)
        case .calendar:
            CalendarPicker(mode: .range) { dateSelection in
                Task { await viewModel.handleDateSelection(for: dateSelection)}
            }
        }
    }
    
    private func isSessionExpired(oldState: AuthState, newState: AuthState) {
        if case .authenticated = oldState, case .unauthorized = newState {
            viewModel.alert = .sessionExpired
        }
    }
}

enum PlannerMemberAlert {
    case sessionExpired
    case error(title: String? = nil, message: String)

    var title: String {
        switch self {
        case .sessionExpired: return "세션 만료"
        case .error(let title, _):
            if let title = title { return title }
            else { return "오류" }
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
        case .sessionExpired: Text("이전의 사용자가 로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(_, let message): Text(message)
        }
    }
}

enum PlannerMemberSheet: Identifiable {
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
