//
//  MyAccountViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/1/26.
//

import SwiftUI
import Combine

/// MyAccountView에서 필요한 데이터와 로직을 제공합니다.
@MainActor
class MyAccountViewModelOld: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: MyAccountViewStateOld = .loading
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: MyAccountAlertOld?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: MyAccountSheetOld?
    
    /// 화면에 표시할 fullScreenCover
    /// - 아무 fullScreenCover도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var fullScreenCover: MyAccountFullScreenCoverOld?
    
    @Published var presentSaveSuccessAlert: Bool = false
    
    /// 현재 사용자
    /// - `subscribeToAuthState()`를 통해 AuthManager의 `currentUser`와 동기화됩니다.
    /// - 로그인 상태가 아닌 경우 `nil`이 됩니다.
    /// - 뷰의 `.task`를 통해 현재 사용자의 정보를 참조하기 위해 사용합니다.
    ///   `.task`가 상태 변경을 감지하면, `prepareDataIfNeeded()`를 호출해 새 사용자를 기준으로 다시 불러온 데이터로 화면을 업데이트합니다.
    @Published var currentUser: CurrentUser?
    
    /// 가장 최근에 데이터를 불러온 시점의 사용자 스냅샷
    /// - 가장 최근에 화면에 표시할 데이터를 불러온 시점의 사용자 정보입니다.
    /// - 어떤 사용자를 기준으로 데이터가 불러와졌는지 확인하거나, 사용자의 변경 여부를 판별하기 위해 사용할 수 있습니다.
    private var lastLoadedUser: CurrentUser?
    
    // MARK: - 사용자 context 관련 프로퍼티 (User Context Properties)
    
    @Published var myRecipesResponse: RecipeBasicsPaged?
    @Published var savedRecipesResponse: RecipeBasicsPaged?
    
    @Published var myKitchenwareCount: Int?
    @Published var myIngredientCount: Int?
    @Published var likedRecipeCount: Int?
    @Published var ratedRecipeCount: Int?
    
    @Published var myIngredients: [IngredientBasic] = []
    @Published var myKitchenwares: [KitchenwareEssential] = []
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성 (Dependencies)
    
    private let auth: AuthProvider
    private let userService = UserService.shared
    private let userPlanService = UserPlanService.shared
    private let userPantryService = UserPantryService.shared
    private let recipeService = RecipeService.shared
    private let kitchenwareService = KitchenwareService.shared
    private let ingredientService = IngredientService.shared
    
    // MARK: - 초기화 (Initialization)
    
    init(auth: AuthProvider = AuthManager.shared) {
        self.auth = auth
        subscribeToPublishers()
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    /// - 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - `validateContext()`를 통해 검증을 통과한 경우에만 데이터를 새로 불러옵니다.
    ///   화면에 표시 중인 데이터가 없거나 사용자가 변경된 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        // 로그인 사용자가 아니면 게스트 전용 커버를 보여주는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateContext() { return }
        
        resetAndLoadAll()
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadAll(completion: continuation.resume)
        }
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    private func loadAll(completion: (() -> Void)? = nil) {
        currentUser = auth.currentUser
        
        // 데이터를 불러오는 시점의 사용자 정보 스냅샷을 저장합니다.
        lastLoadedUser = currentUser
        
        let group = DispatchGroup()
        var errors: [(error: NetworkError, message: String)] = []
        let queue = DispatchQueue(label: "my_account_error_queue")
        
        let loadCompletionHandler: (((NetworkError, String)?) -> Void) = { error in
            if let error = error {
                queue.sync { errors.append(error) }
            }
            group.leave()
        }
        
        group.enter()
        loadMyRecipes(completion: loadCompletionHandler)
        
        group.enter()
        loadMyKitchenwares(completion: loadCompletionHandler)
        
        group.enter()
        loadMyIngredients(completion: loadCompletionHandler)
        
        group.enter()
        loadSavedRecipes(completion: loadCompletionHandler)
        
        group.enter()
        loadLikedRecipeCount(completion: loadCompletionHandler)
        
        group.enter()
        loadRatedRecipeCount(completion: loadCompletionHandler)
        
        group.notify(queue: .main) { [weak self] in
            self?.handleLoadInitialDataCompletion(errors: errors) {
                completion?()
            }
        }
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    private func resetAndLoadAll() {
        // 불러오기 상태 설정 필요 여부를 확인합니다. 앱 실행 후 뷰가 한 번도 보여진 적 없었던 경우에만 실행합니다.
        if viewState != .loaded { viewState = .loading }
        
        loadAll()
    }
    
    private func handleLoadInitialDataCompletion(errors: [(error: NetworkError, message: String)], completion: (() -> Void)? = nil) {
        defer { completion?() }
        
        if let error = errors.first(where: { $0.error.isServiceUnavailable }) {
            viewState = .error(message: error.message)
            return
        }
        
        if errors.count == 1, let error = errors.first {
            viewState = .error(message: error.1)
            return
        }
        
        if 1 < errors.count {
            viewState = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
            return
        }
        
        viewState = .loaded
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
                // 로그인 사용자에서 게스트 사용자로 변경된 경우: 세션 만료 alert을 present 합니다.
//                if self?.lastLoadedUser != nil, case .unauthorized = state {
//                    self?.alert = .sessionExpired
//                }
                
                self?.prepareDataIfNeeded()
//                self?.currentUser = authManager.currentUser // prepareDataIfNeeded 트리거
            }
            .store(in: &cancellables) 
    }
    
    /// 데이터를 불러올 필요성을 검증합니다.
    ///
    /// 로그인 사용자와 게스트 사용자에게 보여져야 할 뷰가 다르기 때문에, 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에
    /// 현재 전역 인증 상태(로그인 유무, 사용자 변경 여부 등)에 따라 필요한 사전 작업을 추가 수행합니다.
    ///
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화하고, 게스트 사용자용 뷰를 표시합니다.
    /// - 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateContext() -> Bool {
        if !auth.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        // 로그인 사용자 변경 여부를 확인합니다. 직전에 뷰가 보여졌던 시점과 다른 사용자인 경우에만 실행합니다.
        if lastLoadedUser != currentUser {
            handleContextForNewUser()
        }
            
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        viewState = .unauthorized
        alert = .sessionExpired
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        viewState = .loading
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        myRecipesResponse = nil
        savedRecipesResponse = nil
        myKitchenwareCount = nil
        myIngredientCount = nil
        likedRecipeCount = nil
        ratedRecipeCount = nil
    }
}

enum MyAccountSheetOld: Identifiable {
    case managementProfile
    case kitchenwarePicker
    case ingredientPicker
    case likedIngredientList
    
    var id: Int { hashValue }
}

enum MyAccountFullScreenCoverOld: Identifiable {
    case recipeEditor
    
    var id: Int { hashValue }
}

enum MyAccountAlertOld: Identifiable {
    case createdRecipe
    case sessionExpired
    case error(message: String)
    
    var id: String {
        switch self {
        case .createdRecipe: return "createdRecipe"
        case .sessionExpired: return "sessionExpired"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .createdRecipe:
            return Alert(
                title: Text("새 레시피 등록 완료"),
                message: Text("새 레시피를 등록했어요."),
                dismissButton: .default(Text("확인"))
            )
        case .sessionExpired:
            return Alert(
                title: Text("세션 만료"),
                message: Text("로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요."),
                dismissButton: .default(Text("확인"))
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

enum MyAccountViewStateOld: Equatable {
    case loading
    case loaded
    case error(message: String)
    case unauthorized
}

extension MyAccountViewModelOld {
    func requireAuthView() { auth.requireAuthView() }
    
    func presentRecipeEditor() {
        fullScreenCover = .recipeEditor
    }
    
    func loadMyRecipes(completion: (((NetworkError, String)?) -> Void)? = nil) {
        guard let currentUser = currentUser else { completion?(nil); return }

        recipeService.fetchAllBasicsByAuthorId(id: currentUser.id, page: 0, size: 6) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myRecipesResponse = response
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "최근 등록한 레시피 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadMyKitchenwares(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userPantryService.fetchKitchenwares { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myKitchenwareCount = response.totalElements
                    let kitchenwares = response.content.map { item in
                        return KitchenwareEssential(id: item.id, name: item.name, imageUrl: item.imageUrl)
                    }

                    self.myKitchenwares = kitchenwares
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "보관함에 추가한 도구 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadMyIngredients(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userPantryService.fetchIngredients(page: 0, size: 10) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myIngredientCount = response.totalElements
                    self.myIngredients = response.content
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "보관함에 추가한 재료 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadIngredientCount(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userPantryService.getIngredientCount { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myIngredientCount = response.count
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "보관함 속 재료 수를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadSavedRecipes(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userService.fetchSavedRecipes(page: 0, size: 6)  { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.savedRecipesResponse = response
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "저장한 레시피 수를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadLikedRecipeCount(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userService.getMyLikedRecipeCount { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.likedRecipeCount = response.count
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "좋아하는 레시피 수를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadRatedRecipeCount(completion: (((NetworkError, String)?) -> Void)? = nil) {
        userService.getMyRatedRecipeCount { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.ratedRecipeCount = response.count
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "평가한 레시피 수를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func addKitchenwares(kitchenwares: [KitchenwareEssential]) {
        userPantryService.addKitchenwares(ids: kitchenwares.map(\.id)) { result in
            switch result {
            case .success: print("성공!")
            case .failure(let networkError): print("실패 ㅜ")
            }
        }
    }
}
