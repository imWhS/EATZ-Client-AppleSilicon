//
//  AddToPlannerViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/11/25.
//

import SwiftUI
import Combine

enum PlannerDatePickerAlert: Identifiable {
    case addToPlannerFailure(message: String)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .addToPlannerFailure(let message): return "addToPlannerFailure_\(message)"
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .error(let message): return "otherError_\(message)"
        }
    }
    
    var alert: Alert {
        switch self {
        case .addToPlannerFailure(let message):
            return Alert(
                title: Text("플래너에 추가 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .userChanged(let dismissAction):
            return Alert(
                title: Text("사용자 변경"),
                message: Text("다른 사용자로 로그인되어 플래너에 추가를 종료할게요."),
                dismissButton: .default(Text("확인"), action: dismissAction)
            )
        case .sessionExpired(let dismissAction):
            return Alert(
                title: Text("세션 만료"),
                message: Text("로그아웃 상태로 전환됐어요. 플래너에 추가를 종료할게요."),
                dismissButton: .default(Text("확인"), action: dismissAction)
            )
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

enum PlannerDatePickerViewState: Equatable {
    case loading
    case loaded
    case unauthorized
    case error(message: String)
}

class PlannerDatePickerViewModel: ObservableObject {
    
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    @Published var viewState: PlannerDatePickerViewState = .loading
    @Published var alert: PlannerDatePickerAlert?
    @Published var currentMonth: Date = Date()
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    @Published var plannedDates: Set<Date> = []
    @Published var selectedDates: [Date] = []

    private var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private let recipeId: Int64
    private var onDismiss: (() -> Void)?
    private var onComplete: (() -> Void)?
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성
    
    private lazy var authManager = AuthManager.shared
    private let userPlanService = UserPlanService.shared
    private let recipeService = RecipeService.shared
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    func setCompleteActions(onDismiss: @escaping () -> Void, onComplete: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        self.onComplete = onComplete
    }
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에도 호출될 수 있습니다.
    func prepareDataIfNeeded() {
        subscribeToAuthState()
        
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser() { return }
        
        // 불러오기 상태 설정 필요 여부를 확인합니다. 앱 실행 후 뷰가 한 번도 보여진 적 없었던 경우에만 실행합니다.
        if viewState != .loaded { viewState = .loading }
        
        loadPlannedDates(for: currentMonth)
    }
    
    func subscribeToAuthState() {
        guard cancellables.isEmpty else { return }
        
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .authenticated:
                    // 재로그인한 경우: 사용자 검증 및 데이터 불러오기를 위해 prepareDataIfNeeded를 다시 호출합니다.
                    self.prepareDataIfNeeded()
                case .unauthorized, .unknown:
                    // 전역 로그아웃 상태가 된 경우: 뷰를 표시할 필요가 없기 때문에, 데이터 불러오기를 하지 않고 즉시 컨텍스트 초기화 및 종료 알림을 처리합니다.
                    self.validateAndPrepareUser()
                }
            }
            .store(in: &cancellables) 
    }

    /// 현재 레시피의 특정 월에 대한 플래너 등록 날짜를 불러옵니다.
    func loadPlannedDates(for month: Date) {
        guard let dateInterval = Calendar.current.dateInterval(of: .month, for: month) else { return }
        
        userPlanService.fetchPlannedDates(recipeId: recipeId, startDate: dateInterval.start, endDate: dateInterval.end) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let dates = response.plannedDates.compactMap { date in
//                        guard let date = EatzDateTimeFormatter.standard.date(from: dateString) else { return nil }
                        return Calendar.current.startOfDay(for: date)
                    }
                    self.plannedDates.formUnion(dates)
                    self.viewState = .loaded
                case .failure(let networkError):
                    self.viewState = .error(message: networkError.userMessage)
                }
            }
        }
    }
    
    func addToPlanner(on date: Date) {
        userPlanService.createPlan(recipeId: recipeId, date: date, priority: 1) { [weak self] result in
            switch result {
            case .success:
                self?.onComplete?()
                self?.onDismiss?()
            case .failure(let networkError):
                // 세션 만료 에러라면, 지역 에러 처리(present alert)를 하지 않고 종료합니다.
                if networkError.isTokenExpiredError { return }
                self?.alert = .addToPlannerFailure(message: networkError.userMessage)
            }
        }
    }
    
    /// 데이터를 불러올 필요성을 확인하기 위해 사용자를 검증하고, 검증 성공 시 현재 사용자 정보를 업데이트합니다.
    /// - 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에, 현재 전역 인증 상태(사용자 변경, 데이터 유무)에 따라 필요한 사전 작업을 수행합니다.
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화합니다.
    ///   단, 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화하고, 뷰를 dismiss 합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateAndPrepareUser() -> Bool {
        if !authManager.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        // 로그인 사용자 변경 여부를 확인합니다. 직전에 뷰가 보여졌던 시점과 다른 사용자인 경우에만 실행합니다.
        if let user = currentUser,
           user.id != authManager.currentUser?.id {
            handleContextForNewUser()
            return false
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        alert = .sessionExpired(dismissAction: onDismiss ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        alert = .userChanged(dismissAction: onDismiss ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        plannedDates = []
        selectedDates = []
        currentUser = nil
    }
}
