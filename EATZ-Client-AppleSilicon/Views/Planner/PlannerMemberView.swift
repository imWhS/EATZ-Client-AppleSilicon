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
    
    @State private var isOverPlanListOffsetYLimit: Bool = false
    @State private var checklistFloatingBarHeight: CGFloat = 0
    
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
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PlannerChecklistFloatingBar(
                    planCount: viewModel.planCountInDateRange,
                    onPresentChecklistTapped: {
                        router.push(.checklist(
                            startDate: viewModel.dateRange.startDate,
                            endDate: viewModel.dateRange.endDate
                        ))},
                    isCompactMode: isOverPlanListOffsetYLimit
                )
                .opacity(viewModel.state == .content ? 1 : 0)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    self.checklistFloatingBarHeight = height
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.state)
            .animation(.easeInOut(duration: 0.3), value: viewModel.planCountInDateRange)
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
            // 해당 날짜/기간에 추가된 플랜이 하나도 없는 경우
            if viewModel.planCountInDateRange == 0 {
                plansEmptyStateHeader
                    .padding(.horizontal, 20)
            }
            planListSection
        }
        .background(Color.backgroundPrimary)
        .animation(.easeInOut(duration: 0.3), value: viewModel.planCountInDateRange)
        .coordinateSpace(name: "scroll")
        .refreshable { await viewModel.refresh() }
    }
    
    private var plansEmptyStateHeader: some View {
        VStack(spacing: 20) {
            Image("add-to-planner-40")
                .foregroundStyle(Color.gray15)
            VStack(spacing: 8) {
                Text("레시피를 플래너에 추가해보세요.")
                    .font(Font.system(size: 17, weight: .semibold))
                Text("원하는 날짜 또는 기간에 요리할 수 있는 레시피를 분류하고, 모든 레시피를 요리하기 위해 준비해야 할 재료와 도구를 정리해서 체크리스트로 만들어드려요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray50)
            }
        }
        .padding(40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
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
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .named("scroll")).minY) { _, minY in
                        guard self.checklistFloatingBarHeight > 0 else { return }
                                            
                        let offsetYLimit = -(self.checklistFloatingBarHeight / 2)
                        let isOverOffsetYLimit = minY < offsetYLimit
                        
                        if self.isOverPlanListOffsetYLimit != isOverOffsetYLimit {
                            self.isOverPlanListOffsetYLimit = isOverOffsetYLimit
                        }
                    }
            }
        )
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

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
