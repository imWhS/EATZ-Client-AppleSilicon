//
//  PlannerRecipePickerViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 1/20/26.
//

import SwiftUI
import Combine

@MainActor
class PlannerRecipePickerViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: PlannerRecipePickerViewState = .idle
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: PlannerRecipePickerAlert?
    
    @Published var isSearchMode: Bool = false
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    @Published var keyword: String = ""
    
    @Published var pagedSavedRecipes: Paged<RecipeBasic> = .initial
    @Published var pagedSearchedRecipes: Paged<RecipeBasic> = .initial

    @Published var savedRecipesState: PlannerRecipePickerSavedRecipesState = .loading
    @Published var searchState: PlannerRecipePickerSearchState = .searching
    @Published var registrationState: PlannerRecipePickerRegistrationState = .idle
    
    private var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private let date: Date
    private var onDismiss: (() -> Void)?
    private var onComplete: (() -> Void)?
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성
    
    private let auth: AuthProvider
    private let userPlanService = UserPlanService.shared
    private let recipeService = RecipeService.shared
    private let userService = UserService.shared
    
    init(date: Date, auth: AuthProvider = AuthManager.shared) {
        self.date = date
        self.auth = auth
    }
    
    func setActions(dismissAction: @escaping () -> Void, completeAction: @escaping () -> Void) {
        self.onDismiss = dismissAction
        self.onComplete = completeAction
    }
    
    func startSearch() {
        isSearchMode = true
    }
    
    func cancelSearch() {
        isSearchMode = false
        resetSearchState()
    }
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에도 호출될 수 있습니다.
    func prepareDataIfNeeded() {
        subscribeToPublishers()
        
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser() { return }
        
        viewState = .idle
        
        // 검색 모드 활성화 여부에 따라 필요한 데이터만 불러옵니다.
        // 뷰는 기본적으로 초기에 저장한 레시피 목록을 보여주지만, 뷰가 다시 화면에 보여진 경우(다른 sheet에 가려졌다가 다시 보여진 경우)에는 저장한 레시피 목록, 레시피 검색 결과 목록 중 하나를 보여줄 수 있기에, 레시피 검색 결과 목록 불러오기 분기 여부도 확인합니다.
        if isSearchMode {
            // 검색 모드일 때, 키워드가 유효하고 아직 레시피 검색 결과 목록이 불러와지지 않은 경우에만 레시피 검색 결과 목록을 불러옵니다.
            // 단, 로그인 상태의 뷰가 화면에 보여졌을 때(이전에 present 된 적 있을 때) 이미 불러온 레시피 검색 결과 목록 데이터가 있는 .searched 상태라면 기존 스크롤 위치를 유지하기 위해 불러오지 않습니다.
            if !keyword.isEmpty && searchState != .searched {
                searchState = .searching
                searchRecipes(keyword: keyword, page: 0)
            }
        } else {
            // 검색 모드가 아닐 때, 아직 저장한 레시피 목록이 불러와지지 않은 경우에만 저장한 레시피 목록을 불러옵니다.
            // 단, 로그인 상태의 뷰가 화면에 보여졌을 때(이전에 present 된 적 있을 때), 이미 불러온 저장한 레시피 목록 데이터가 있는 .loaded 상태라면, 기존 스크롤 위치를 유지하기 위해 불러오지 않습니다.
            if savedRecipesState != .loaded {
                savedRecipesState = .loading
                loadSavedRecipes(page: 0)
            }
        }
    }
    
    func loadMoreSavedRecipes() {
        guard pagedSavedRecipes.hasNextPage,
              !pagedSavedRecipes.isLoadingNextPage else { return }
        
        pagedSavedRecipes.isLoadingNextPage = true
        loadSavedRecipes(page: pagedSavedRecipes.page + 1) {
            self.pagedSavedRecipes.isLoadingNextPage = false
        }
    }
    
    func loadMoreSearchedRecipes() {
        guard !keyword.isEmpty,
                pagedSearchedRecipes.hasNextPage,
                !pagedSearchedRecipes.isLoadingNextPage else { return }
        
        pagedSearchedRecipes.isLoadingNextPage = true
        searchRecipes(keyword: keyword, page: pagedSearchedRecipes.page + 1) {
            self.pagedSearchedRecipes.isLoadingNextPage = false
        }
    }
    
    private func subscribeToPublishers() {
        guard let authManager = auth as? AuthManager else { return }
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
                    // 전역 로그아웃 상태가 된 경우: 데이터 불러오기를 하지 않고, 즉시 컨텍스트 초기화 및 종료 알림을 처리합니다.
                    self.validateAndPrepareUser()
                }
            }
            .store(in: &cancellables) 
        
        $keyword
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 0.5초 기다림 (디바운스)
            .removeDuplicates() // 같은 검색어는 무시
            .sink { [weak self] keyword in
                guard let self = self else { return }
                if keyword.isEmpty {
                    self.pagedSearchedRecipes = .initial
                } else {
                    self.searchState = .searching
                    self.searchRecipes(keyword: keyword, page: 0)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 데이터를 불러올 필요성을 확인하기 위해 사용자를 검증하고, 검증 성공 시 현재 사용자 정보를 업데이트합니다.
    /// - 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에, 현재 전역 인증 상태(사용자 변경, 데이터 유무)에 따라 필요한 사전 작업을 수행합니다.
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화합니다.
    ///   단, 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화하고, 뷰를 dismiss 합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateAndPrepareUser() -> Bool {
        if !auth.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        // 로그인 사용자 변경 여부를 확인합니다. 직전에 뷰가 보여졌던 시점과 다른 사용자인 경우에만 실행합니다.
        if let user = currentUser,
           user.id != auth.currentUser?.id {
            handleContextForNewUser()
            return false
        }
        
        currentUser = auth.currentUser
        return true
    }
    
    private func resetSearchState() {
        keyword = ""
        pagedSearchedRecipes = .initial
        searchState = .searching
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
        pagedSavedRecipes = .initial
        savedRecipesState = .loading
        resetSearchState()
        registrationState = .idle
        currentUser = nil
    }
}

extension PlannerRecipePickerViewModel {
    private func loadSavedRecipes(page: Int, completion: @escaping () -> Void = {}) {
        print("DBG | \(#function)")
        userService.fetchSavedRecipes(page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let content = response.content
                    
                    if page == 0 && content.isEmpty {
                        self.pagedSavedRecipes = .initial
                        self.savedRecipesState = .empty
                    } else {
                        self.pagedSavedRecipes.appendPage(
                            content,
                            page: response.page,
                            hasNextPage: response.hasNext,
                            totalElements: response.totalElements
                        )
                        self.savedRecipesState = .loaded
                    }
                case .failure(let networkError):
                    if page == 0 {
                        self.savedRecipesState = .error(networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                        self.savedRecipesState = .loaded
                    }
                }
                completion()
            }
        }
    }
    
    private func searchRecipes(keyword: String, page: Int, completion: @escaping () -> Void = {}) {
        recipeService.search(keyword: keyword, page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let content = response.content
                    if page == 0 && content.isEmpty {
                        self.pagedSearchedRecipes = .initial
                        self.searchState = .empty
                    } else {
                        self.pagedSearchedRecipes.appendPage(
                            content,
                            page: response.page,
                            hasNextPage: response.hasNext,
                            totalElements: response.totalElements
                        )
                        self.searchState = .searched
                    }
                    
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedSearchedRecipes = .initial
                        self.searchState = .error( networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                        self.searchState = .searched
                    }
                }
                completion()
            }
        }
    }
    
    func addToPlanner(recipeId: Int64) {
        registrationState = .submitting
        userPlanService.createPlan(recipeId: recipeId, date: date, priority: 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.registrationState = .succeeded
                    self.onComplete?()
                    self.onDismiss?()
                case .failure(let networkError):
                    self.registrationState = .idle
                    self.alert = .addToPlannerFailure(message: networkError.userMessage)
                }
            }
        }
    }
}

enum PlannerRecipePickerSearchState: Equatable {
    case searching
    case searched
    case empty
    case error(String)
}

enum PlannerRecipePickerSavedRecipesState: Equatable {
    case loading
    case loaded
    case empty
    case error(String)
}

enum PlannerRecipePickerRegistrationState: Equatable {
    case idle
    case submitting
    case succeeded
}

enum PlannerRecipePickerAlert: Identifiable {
    case addToPlannerFailure(message: String)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .addToPlannerFailure(let message): return "plannerFailure_\(message)"
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .error: return "error"
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

enum PlannerRecipePickerViewState {
    case idle
    case unauthorized
    case error(message: String)
}

