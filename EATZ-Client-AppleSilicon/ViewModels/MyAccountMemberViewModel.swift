//
//  MyAccountGuestViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/31/26.
//

import SwiftUI

/// MyAccountMemberView에서 필요한 데이터와 로직을 제공합니다.
@MainActor
class MyAccountMemberViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰가 화면에 보여줄 최상위 서브뷰를 분기하기 위해 사용합니다.
    @Published var state: MyAccountMemberState = .initialLoading
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: MyAccountMemberAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: MyAccountMemberSheet?
    
    /// 화면에 표시할 fullScreenCover
    /// - 아무 fullScreenCover도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var fullScreenCover: MyAccountMemberFullScreenCover?
    
    @Published var myRecipesPaged: RecipeBasicsPaged?
    @Published var savedRecipesPaged: RecipeBasicsPaged?
    
    @Published var myKitchenwareCount: Int?
    @Published var myIngredientCount: Int?
    @Published var likedRecipeCount: Int?
    @Published var ratedRecipeCount: Int?
    
    var myRecipeCount: Int? {
        myRecipesPaged?.totalElements
    }
    
    var savedRecipeCount: Int? {
        savedRecipesPaged?.totalElements
    }
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    private var myIngredients: [IngredientBasic] = []
    private var myKitchenwares: [KitchenwareEssential] = []
    
    private let authManager: AuthManager
    
    private var member: CurrentUser? {
        self.authManager.currentUser
    }
    
    // MARK: - 의존성 (Dependencies)
    
//    private let userService = UserService.shared.shared
//    private let userPlanService = UserPlanService.shared.shared
//    private let userPantryService = UserPantryService.shared.shared
//    private let recipeService = RecipeService.shared.shared
//    private let kitchenwareService = KitchenwareService.shared.shared
//    private let ingredientService = IngredientService.shared.shared

    // MARK: - 초기화 (Initialization)
    
    init(_ authManager: AuthManager) {
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
            state = .initialLoading
        }
        
        loadAll()
    }
    
    /// 조건 없이 뷰 데이터를 불러와서 뷰를 새로 고칩니다.
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadAll(completion: continuation.resume)
        }
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    /// 모든 뷰 데이터를 불러옵니다.
    private func loadAll(completion: (() -> Void)? = nil) {
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
    
    private func handleLoadInitialDataCompletion(errors: [(error: NetworkError, message: String)], completion: (() -> Void)? = nil) {
        defer { completion?() }
        
        if let error = errors.first(where: { $0.error.isServiceUnavailable }) {
            state = .error(message: error.message)
            return
        }
        
        if errors.count == 1, let error = errors.first {
            state = .error(message: error.1)
            return
        }
        
        if 1 < errors.count {
            state = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
            return
        }
        
        state = .content
    }
}

extension MyAccountMemberViewModel {
    func createRecipeCountLabel(_ recipeCount: Int?) -> String? {
        if let recipeCount = recipeCount, 0 < recipeCount {
            return "\(recipeCount)개의 레시피"
        } else { return nil }
    }
    
    func presentRecipeEditor() {
        fullScreenCover = .recipeEditor
    }
    
    func requireAuthView() {
        authManager.requireAuthView()
    }
    
    func loadMyRecipes(completion: (((NetworkError, String)?) -> Void)? = nil) {
        guard let currentUser = member else { completion?(nil); return }
        RecipeService.shared.fetchAllBasicsByAuthorId(id: currentUser.id, page: 0, size: 6) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myRecipesPaged = response
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "최근 등록한 레시피 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadMyKitchenwares(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserPantryService.shared.fetchKitchenwares { [weak self] result in
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
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "보관함 속의 도구 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadMyIngredients(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserPantryService.shared.fetchIngredients(page: 0, size: 10) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myIngredientCount = response.totalElements
                    self.myIngredients = response.content
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "보관함 속의 재료 목록을 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadSavedRecipes(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserService.shared.fetchSavedRecipes(page: 0, size: 6)  { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.savedRecipesPaged = response
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "저장한 레시피 수를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadLikedRecipeCount(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserService.shared.getMyLikedRecipeCount { [weak self] result in
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
        UserService.shared.getMyRatedRecipeCount { [weak self] result in
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
        UserPantryService.shared.addKitchenwares(ids: kitchenwares.map(\.id)) { result in
            if case .failure(let networkError) = result {
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
}
