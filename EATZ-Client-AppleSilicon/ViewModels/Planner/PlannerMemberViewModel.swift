//
//  PlannerMemberViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI
import Alamofire

/// PlannerMemberView에서 필요한 데이터와 로직을 제공합니다.
@MainActor
class PlannerMemberViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var state: PlannerMemberState = .loading
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: PlannerMemberAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: PlannerMemberSheet?
    
    @Published var reportResource: ReportResource?
    
    // MARK: - 사용자 context 관련 프로퍼티 (User Context Properties)
    
    /// 지정한 날짜 범위 내 날짜 별로 그룹화 된 플랜 목록입니다.
    /// - 뷰가 PlannerPlanList를 통해 날짜 별 플랜 목록을 보여주기 위해 사용할 데이터 소스입니다.
    /// - 플랜들을 날짜 별로 그룹화할 때 `String`을 사용해 `EatzDateTimeFormatters.standard` 타입의 `"1994-03-08"`처럼 날짜를 표현합니다. 특정 날짜를 빠르고 안전하게 찾기 위함입니다.
    /// - 플랜 목록들을 날짜 별로 관리하기 위해 `key`는  날짜 문자열, `value`는 해당 날짜에 등록된 `PlannerPlan` 배열로 구성된 `Dictionary` 타입을 사용합니다.
    @Published var plansByDate: [String: [PlannerPlan]] = [:]
    
    /// 지정한 날짜 범위입니다.
    /// - 모든 데이터 조회와 화면 표시에 사용하는 데이터 소스입니다.
    /// - 뷰 최초 진입 시점인 '오늘' 날짜를 시작으로 총 7일의 기간을 초기 날짜 범위 `dateRange`로 설정합니다.
    /// - 날짜 범위 내 플랜 목록은 뷰 모델 초기화 시점이 아닌, 뷰가 화면에 보여지는 시점(`.task` 등)에 `prepareDataIfNeeded`를 호출해 불러옵니다.
    @Published var dateRange: (startDate: Date, endDate: Date) = PlannerViewModel.initialDateRange {
        didSet {
            displayedDates = PlannerViewModel.generateDisplayDates(between: dateRange)
        }
    }
    
    /// 뷰가 PlannerPlanList를 통해 날짜 별 플랜 목록을 표시할 때 사용하는 날짜 목록입니다.
    /// - 뷰에서 다양한 포맷으로 날짜를 화면에 표시할 수 있도록, `Date`를 사용해 날짜를 표현합니다.
    /// - `dateRange` 내의 모든 날짜가 연속된 하루 단위로 포함됩니다.
    /// - `dateRange` 값에 의존하기 때문에, `dateRange`의 값 변경과 동기화됩니다.
    /// - `dateRange`의 값에 의존하지만, 날짜 계산 비용이 비싸기 때문에 연산 프로퍼티가 아닌, 저장 프로퍼티로 선언합니다.
    @Published var displayedDates: [Date] = PlannerViewModel.generateDisplayDates(between: PlannerViewModel.initialDateRange)
    
    /// 지정한 기간 내 등록된 전체 플랜 수입니다.
    /// - `plansByDate` 값에 의존하는 연산 프로퍼티여서, 생명 주기가 동기화됩니다.
    var planCountInDateRange: Int {
        var count = 0
        for plans in plansByDate.values {
            count += plans.count
        }
        return count
    }
    
    // MARK: - 기본 설정 프로퍼티
    
    /// 날짜 범위의 초기 기본 값입니다.
    /// - '오늘(호출한 시점)' 날짜를 시작으로 총 7일의 기간을 초기 날짜 범위 `dateRange`로 설정합니다.
    private static var initialDateRange: (startDate: Date, endDate: Date) = {
        let now = Date()
        
        let today = Calendar.current.startOfDay(for: now)
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: today) ?? today
        return (today, endDate)
    }()
    
    // MARK: - 기타 프로퍼티
    
    private let authManager: AuthManager
    
    // MARK: - 초기화 (Initialization)
    
    init(_ authManager: AuthManager) {
        // dateRange 초기화 코드는 dateRange 연산 프로퍼티로 대체합니다.
        
        self.authManager = authManager
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 컨텍스트나 뷰 상태 등을 먼저 확인해서, 필요한 경우에만 뷰 데이터를 불러옵니다.
    /// - 데이터 불러오기 진입점입니다.
    func prepareDataIfNeeded() {
        // 이미 뷰 데이터가 최소 한 번 불러와져 있는 경우(.loaded)엔 백그라운드에서 조용히 뷰 데이터를 업데이트합니다.
        // 뷰 데이터를 이미 불러오는 중(.loading)이었거나, 오류(.error)가 발생한 상황이었다면
        // 명시적으로 데이터를 불러오고 있는 상태임을 화면에 표시하기 위해 .loading으로 설정합니다.
        if state != .content {
            state = .loading
        }
        
        loadAll()
    }
    
    /// 조건 없이 뷰 데이터를 불러와서, 뷰를 새로 고칩니다.
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadAll(completion: continuation.resume)
        }
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    private func loadAll(completion: (() -> Void)? = nil) {
        loadPlans(completion: completion)
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        dateRange = Self.initialDateRange
        plansByDate = [:]
    }
}

extension PlannerMemberViewModel {
    func requireAuthView() { authManager.requireAuthView() }
    
    /// 새 날짜 범위를 설정합니다.
    /// - 뷰에서 CalendarPicker를 통해 날짜 범위를 새로 설정했을 때 호출합니다.
    /// - CalendarPickerDateSelection에서 추출한 시작 날짜와 끝 날짜를 이용해 관련 프로퍼티의 값을 설정합니다.
    func handleDateSelection(for dateSelection: CalendarPickerDateSelection?) async {
        guard let selection = dateSelection else { return }
        
        if let newDateRange = convertToDateRange(from: selection) {
            dateRange = newDateRange
        } else {
            clearAllContextData()
        }
    }
    
    /// CalendarPicker가 반환한 선택 결과 CalendarPickerDateSelection에서 날짜 범위의 시작 날짜와 마지막 날짜로 구성된 `(Date, Date)` 타입으로 변환합니다.
    private func convertToDateRange(from selection: CalendarPickerDateSelection) -> (startDate: Date, endDate: Date)? {
        switch selection {
        case .range(let startDate, let endDate): return (startDate, endDate)
        case .multiple(let dates):
            if let minimum = dates.min(), let maximum = dates.max() {
                return (minimum, maximum)
            } else {
                return nil
            }
        case .single(let date): return (date, date)
        }
    }
    
    /// 주요 데이터를 초기화하고, 및 서버 데이터 불러오기를 처리합니다.
    private func loadPlans(completion: (() -> Void)? = nil) {
        UserPlanService.shared.fetchPlans(dateRange.startDate, dateRange.endDate) { [weak self] result in
            guard let self = self else { completion?(); return }
            
            // 서버로부터 데이터를 응답 받은 시점에 전역 게스트 상태인 경우, 데이터 불러오기 처리를 하지 않습니다.
//            guard self.authManager.isLoggedIn else { completion?(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let plans):
                    self.plansByDate = self.groupPlansByDate(plans: plans)
                    self.state = .content
                case .failure(let error):
                    if case .content = self.state {
                        self.alert = .error(message: error.userMessage)
                    } else {
                        self.state = .error(message: error.userMessage)
                    }
                }
                
                completion?()
            }
        }
    }
    
    /// 개별 플랜 항목(PlannerPlanItem)에 대한 액션을 처리합니다.
    func handlePlanItemAction(plan: PlannerPlan, action: PlannerPlanItemAction) {
        switch action {
        case .removeFromPlanner: removeFromPlanner(for: plan)
        case .addToPlanner: sheet = .plannerDatePicker(recipeId: plan.recipeId)
        case .like, .unlike: toggleRecipeLikedState(for: plan) // PlannerView 및 이를 포함한 서브뷰의 UI에는 영향이 없고, 액션 메뉴 내부 상태만 변경됩니다.
        case .save, .unsave: toggleRecipeSavedState(for: plan) // PlannerView 및 이를 포함한 서브뷰의 UI에는 영향이 없고, 액션 메뉴 내부 상태만 변경됩니다.
        case .report:
            handleReportRecipe(
                recipeId: plan.recipeId,
                recipeTitle: plan.recipeTitle,
                authorId: plan.recipeAuthorId,
                authorUsername: plan.recipeAuthorUsername)
        }
    }
    
    private func handleReportRecipe(recipeId: Int64, recipeTitle: String, authorId: Int64, authorUsername: String) {
        reportResource = ReportResource(id: recipeId, authorId: authorId, authorUsername: authorUsername, type: .RECIPE, content: recipeTitle)
    }
    
    /// 특정 플랜에 추가된 레시피의 좋아요 상태를 토글합니다.
    private func toggleRecipeLikedState(for plan: PlannerPlan) {
        let recipeId = plan.recipeId
        let originalLiked = plan.likedRecipeByUser
        
        let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updatePlans(with: recipeId) { plan in
                        plan.likedRecipeByUser = !originalLiked
                    }
                case .failure(let networkError):
                    self.alert = .error(title: "레시피 좋아요 토글 실패", message: networkError.userMessage)
                }
            }
        }
        
        if originalLiked { RecipeLikeService.shared.unlikeRecipe(for: recipeId, completion: completionHandler) }
        else { RecipeLikeService.shared.likeRecipe(for: recipeId, completion: completionHandler) }
    }
    
    /// 특정 플랜에 추가된 레시피의 저장 상태를 토글합니다.
    private func toggleRecipeSavedState(for plan: PlannerPlan) {
        let recipeId = plan.recipeId
        let originalSaved = plan.savedRecipeByUser
        
        let completionHandler: (Result<Empty, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updatePlans(with: recipeId) { plan in
                        plan.savedRecipeByUser = !originalSaved
                    }
                case .failure(let networkError):
                    self.alert = .error(title: "레시피 저장 토글 실패", message: networkError.userMessage)
                }
            }
        }
        
        if originalSaved { UserService.shared.unsaveRecipe(for: recipeId, completion: completionHandler) }
        else { UserService.shared.saveRecipe(for: recipeId, completion: completionHandler) }
    }
    
    /// 특정 ID의 레시피가 추가되어 있는 모든 플랜을 찾아, `handler`를 통해 플랜의 상태를 변경합니다.
    ///
    /// `handler` 클로저의 파라미터 `PlannerPlan`이 구조체 상수이기 때문에,
    ///  클로저를 통한 변경이 바로 반영되도록 `inout`을 사용해 참조를 전달합니다.
    private func updatePlans(with recipeId: Int64, handler: (inout PlannerPlan) -> Void) {
        let locations = findPlanLocationsByRecipe(recipeId: recipeId)
        
        // 플래너에서 ID에 해당하는 레시피가 추가된 모든 플랜의 인덱스를 찾습니다.
        for location in locations {
            let dateKey = EatzDateTimeFormatters.standard.string(from: location.scheduledAt)
            guard var plans = plansByDate[dateKey] else { continue }
            if plans.indices.contains(location.index) {
                handler(&plans[location.index])
                self.plansByDate[dateKey] = plans
            }
        }
    }

    /// 날짜 별로 그룹화 된 플랜 목록 `plansByDate`에서 특정 ID의 레시피가 추가되어 있는 모든 플랜의 위치(날짜, 인덱스)를 찾습니다.
    private func findPlanLocationsByRecipe(recipeId: Int64) -> [PlannerLocation] {
        var locations: [PlannerLocation] = []
        
        for date in displayedDates {
            let dateKey = EatzDateTimeFormatters.standard.string(from: date)
            guard let plans = plansByDate[dateKey] else { continue }
            let indexes = plans.enumerated()
                .filter { $0.element.recipeId == recipeId }
                .map { $0.offset }
            
            locations.append(contentsOf: indexes.map { PlannerLocation(scheduledAt: date, index: $0) })
        }
        
        return locations
    }
    
    private func removeFromPlanner(for plan: PlannerPlan) {
        let dateKey = EatzDateTimeFormatters.standard.string(from: plan.scheduledAt)
        
        guard let plans = plansByDate[dateKey],
              let index = plans.firstIndex(where: { $0.id == plan.id }) else {
            self.alert = .error(
                title: "플래너에서 제거 실패",
                message: "해당 날짜 또는 레시피가 올바르지 않은 것 같아요. 다시 시도해주세요.")
            return
        }
        
        let originalPlans = plans
        
        if plansByDate[dateKey]?.indices.contains(index) == true {
            plansByDate[dateKey]?.remove(at: index)
        } else { return }
        
        UserPlanService.shared.deletePlan(for: plan.id) { [weak self] result in
            guard let self = self else { return }
            guard case .failure(let networkError) = result else { return }
            
            self.alert = .error(title: "플래너에서 제거 실패", message: networkError.userMessage)
            self.plansByDate[dateKey] = originalPlans
        }
    }
    
    /// 날짜를 기준으로 플랜들을 grouping 합니다.
    /// - Ex. `["2025-08-20": [PlanDto, PlanDto], "2025-08-21": [PlanDto]]`
    private func groupPlansByDate(plans: [PlannerPlan]) -> [String: [PlannerPlan]] {
        return Dictionary(grouping: plans, by: { plan in
                // Date 객체를 "yyyy-MM-dd" 형식의 String 키로 변환해서 그룹화합니다.
                return EatzDateTimeFormatters.standard.string(from: plan.scheduledAt)
            })
    }
    
    /// 날짜 범위의 시작 날짜부터 종료 날짜까지 하루 단위로 연속된 날짜 배열을 생성합니다.
    private static func generateDisplayDates(between dateRange: (startDate: Date, endDate: Date)) -> [Date] {
        let calendar = Calendar.current
        let endDate = dateRange.endDate
        var displayDates: [Date] = []
        var currentDate = dateRange.startDate
        
        while (currentDate <= endDate) {
            displayDates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return displayDates
    }
}

enum PlannerMemberState: Equatable {
    case loading
    case content
    case error(message: String)
}

/// 뷰의 데이터 소스 `plansByDate` 내에서 특정 아이템의 위치를 나타내는 '좌표' 역할을 합니다.
struct PlannerLocation {
    let scheduledAt: Date
    let index: Int
}
