//
//  RecipeBasicListViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/1/25.
//

import SwiftUI
import Combine

class RecipeBasicListViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: RecipeBasicListViewState = .loading
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RecipeBasicListAlert?
    
    @Published var loadNextPageErrorMessage: String?
    
    // MARK: - 사용자 context 관련 프로퍼티 (User Context Properties)
    
    @Published var pagedRecipes: Paged<RecipeBasic> = .initial
    
    /// 현재 사용자
    /// - `subscribeToAuthState()`를 통해 AuthManager의 `currentUser`와 동기화됩니다.
    /// - 로그인 상태가 아닌 경우 `nil`이 됩니다.
    /// - 뷰의 `.task`를 통해 현재 사용자의 정보를 참조하기 위해 사용합니다.
    ///   `.task`가 상태 변경을 감지하면, `prepareDataIfNeeded()`를 호출해 새 사용자를 기준으로 다시 불러온 데이터로 화면을 업데이트합니다.
    @Published var currentUser: CurrentUser?
    
    var totalElementsLabel: String {
        let count = pagedRecipes.totalElements
        return 0 < count ? "\(count)개의 레시피" : "레시피"
    }
    
    /// 가장 최근에 데이터를 불러온 시점의 사용자 스냅샷
    /// - 가장 최근에 화면에 표시할 데이터를 불러온 시점의 사용자 정보입니다.
    /// - 어떤 사용자를 기준으로 데이터가 불러와졌는지 확인하거나, 사용자의 변경 여부를 판별하기 위해 사용할 수 있습니다.
    private var lastLoadedUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private var dismissAction: (() -> Void)?
    
    private let fetcher: (Int, @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void) -> Void
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성 (Dependencies)
    
    private let auth: AuthProvider
    
    // MARK: - 초기화 (Initialization)
    
    init(fetcher: @escaping (Int, @escaping (Result<RecipeBasicsPaged, NetworkError>) -> Void) -> Void, auth: AuthProvider = AuthManager.shared) {
        self.fetcher = fetcher
        self.auth = auth
        self.currentUser = auth.currentUser
        
        subscribeToAuthState()
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    /// - 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - `validateContext()`를 통해 검증을 통과한 경우에만 데이터를 새로 불러옵니다.
    ///   화면에 표시 중인 데이터가 없거나 사용자가 변경된 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateContext() { return }
        
        resetAndLoadAll()
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    private func loadAll() {
        currentUser = auth.currentUser
        
        // 데이터를 불러오는 시점의 사용자 정보 스냅샷을 저장합니다.
        lastLoadedUser = currentUser
        
        loadPage()
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    private func resetAndLoadAll() {
        // viewState가 .error일 때 등과 같이, 뷰에서 prepareDataIfNeeded를 다시 호출할 수도 있습니다.
        // 이때 사용자에게 데이터를 불러오고 있다는 피드백을 주기 위해 초기 데이터와 동일하더라도 viewState를 .loading으로 명시적으로 설정합니다.
        viewState = .loading
        
        loadAll()
    }
    
    /// 외부 데이터 스트림을 구독합니다.
    /// - 초기화(`init`) 시점에 단 한 번만 호출되어야 합니다.
    private func subscribeToPublishers() {
        guard cancellables.isEmpty else { return }
        subscribeToAuthState()
    }
    
    /// AuthProvider의 `authState`를 구독합니다.
    /// - 사용자 인증 상태 변경을 감지하고, 새 상태로 변경된 경우, 이를 현재 사용자(`currentUser`)와 동기화합니다.
    /// - 사용자 상태 변경에 따른 화면 업데이트 처리는 `currentUser`를 참조하는 `.task` 동작에 위임합니다.
    private func subscribeToAuthState() {
        guard let authManager = auth as? AuthManager else { return }
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .authenticated(let user) = state {
                                    self?.currentUser = user
                                } else {
                                    self?.currentUser = nil
                                }
                self?.prepareDataIfNeeded()
            }
            .store(in: &cancellables) 
    }
    
    /// 데이터를 불러올 필요성을 검증합니다.
    ///
    /// 로그인 사용자만 접근 가능한 뷰이기 때문에, 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에
    /// 현재 전역 인증 상태(로그인 유무, 사용자 변경 여부 등)에 따라 필요한 사전 작업을 추가 수행합니다.
    ///
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화합니다.
    /// - 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화하고, 뷰를 dismiss 합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateContext() -> Bool {
        if currentUser != nil && lastLoadedUser == currentUser {
            return false
        }
        
        if !auth.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        // 로그인 사용자 변경 여부를 확인합니다. 직전에 뷰가 보여졌던 시점과 다른 사용자인 경우에만 실행합니다.
        if lastLoadedUser != currentUser {
            handleContextForNewUser()
            return true
        }
        
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        viewState = .unauthorized
        alert = .sessionExpired(dismissAction: dismissAction ?? {})
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        viewState = .loading
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        pagedRecipes = .initial
    }
}

extension RecipeBasicListViewModel {
    func setDismissAction(_ action: @escaping () -> Void) {
        dismissAction = action
    }
    
    func loadNextPage() {
        guard !pagedRecipes.isLoadingNextPage, pagedRecipes.hasNextPage else { return }
        pagedRecipes.isLoadingNextPage = true
        loadPage(pagedRecipes.page + 1) { self.pagedRecipes.isLoadingNextPage = false }
    }
    
    func removeRecipe(for id: Int64) {
        pagedRecipes.remove(id)
        
        if pagedRecipes.isEmpty {
            pagedRecipes = .initial
            viewState = .empty
        }
    }
    
    func toggleSavedState(for id: Int64) {
        pagedRecipes.updateItem(for: id) { $0.savedByUser.toggle() }
    }
    
    private func loadPage(_ page: Int = 0, completion: @escaping () -> Void = {}) {
        fetcher(page) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let content = response.content
                    
                    if page == 0 && content.isEmpty {
                        self.pagedRecipes = .initial
                        self.viewState = .empty
                        break
                    }
                    
                    self.pagedRecipes.appendPage(
                        content,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements)
                    self.viewState = .loaded
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedRecipes = .initial
                        self.viewState = .error(message: networkError.userMessage)
                    } else {
                        self.loadNextPageErrorMessage = networkError.userMessage
                        self.viewState = .loaded
                    }
                }
                completion()
            }
        }
    }
}

enum RecipeBasicListViewState: Equatable {
    case loading
    case loaded
    case empty
    case error(message: String)
    case unauthorized
}

enum RecipeBasicListAlert: Identifiable {
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .sessionExpired: return "sessionExpired"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .sessionExpired(let dismissAction):
            return Alert(
                title: Text("세션 만료"),
                message: Text("로그아웃 상태로 전환됐어요. 내 재료 보관함을 종료할게요."),
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
