//
//  ExploreRecipesViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import SwiftUI
import Alamofire

@MainActor
class ExploreRecipesViewModel: ObservableObject {
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: ExploreRecipesViewState = .initialLoading
    
    @Published var pagedRecipes: Paged<ExploreRecipe> = .initial
    
    @Published var navigationRoute: ViewRoute?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: ExploreRecipesSheet?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ExploreAlert?
    
    @Published var reportResource: ReportResource?
    
    @Published var pendingLikeRecipeIds: Set<Int64> = []
    @Published var pendingSaveRecipeIds: Set<Int64> = []
    
    private var filters = ExploreFilters()
    private var sort: ExploreRecipesSort = .TRENDING
    
    private let auth: AuthProvider
    private let userService = UserService.shared
    private let recipeService = RecipeService.shared
    private let likeService = RecipeLikeService.shared
    
    /// 검색 요청 ID입니다.
    ///
    /// - 유효한 레시피 목록 요청만 남겨야 할 때 사용합니다.
    private var recipesRequestId: UUID?
    
    /// 가장 최근에 데이터를 불러온 시점의 사용자 ID입니다.
    ///
    /// 데이터가 어떤 사용자를 기준으로 불러와졌는지 확인할 때 사용할 수 있습니다.
    private var lastLoadedUserId: Int64?
    
    
    init(auth: AuthProvider = AuthManager.shared) {
        self.auth = auth
    }
    
    func updateListOptions(newFilters: ExploreFilters, newSort: ExploreRecipesSort) {
        if filters == newFilters && sort == newSort { return }
        
        filters = newFilters
        sort = newSort
        
        resetAndLoadAll()
    }
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    ///
    /// - 진입점 역할을 합니다.
    /// - 로그인 사용자가 변경되었거나 화면에 표시 중인 데이터가 없는 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if case .loaded = viewState, lastLoadedUserId == auth.currentUser?.id { return }
        resetAndLoadAll()
    }
    
    func setupForLoad() {
        lastLoadedUserId = auth.currentUser?.id
        recipesRequestId = UUID()
        resetListState()
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우: Ex. 필터, 정렬 옵션 변경 시
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    func resetAndLoadAll() {
        viewState = .initialLoading
        pagedRecipes = .initial
        
        setupForLoad()
        loadRecipes(page: 0)
    }
    
    func refresh() async {
        setupForLoad()
        await withCheckedContinuation { continuation in
            self.loadRecipes(page: 0, completion: continuation.resume)
        }
    }
    
    func loadMoreRecipes() {
        guard viewState == .loaded,
              pagedRecipes.hasNextPage,
              !pagedRecipes.isLoadingNextPage
        else { return }
        pagedRecipes.isLoadingNextPage = true
        
        Task { [weak self] in // self를 약하게 잡아, View가 화면에서 사라지는 상황 등이 발생하면 불러오기를 취소합니다.
            guard let self = self else { return }
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            loadRecipes(page: pagedRecipes.page + 1) { [weak self] in
                self?.pagedRecipes.isLoadingNextPage = false
            }
        }
    }
    
    func handleItem(for recipe: ExploreRecipe, action: ExploreRecipeItemAction) {
        switch action {
        case .save: handleToggleSave(for: recipe.id)
        case .like: handleToggleLike(for: recipe.id)
        case .comment: self.navigationRoute = .comment(recipeId: recipe.id)
        case .addToPlanner: presentAddToPlanner(for: recipe.id)
        case .report: handleReportRecipe(for: recipe)
        }
    }
    
    private func handleToggleSave(for id: Int64) {
        guard !pendingSaveRecipeIds.contains(id) else { return }
        
        auth.performWhenLoggedIn {
            self.toggleSave(of: id)
        }
    }
    
    private func handleToggleLike(for id: Int64) {
        guard !pendingLikeRecipeIds.contains(id) else { return }
        
        auth.performWhenLoggedIn {
            self.toggleLike(of: id)
        }
    }
    
    private func handleReportRecipe(for recipe: ExploreRecipe) {
        reportResource = ReportResource(
            id: recipe.id,
            authorId: recipe.authorId,
            authorUsername: recipe.authorUsername,
            type: .RECIPE,
            content: recipe.title)
    }
    
    private func loadRecipes(page: Int, completion: @escaping () -> Void = {}) {
        recipeService.fetchExploreRecipes(
            searchCriteria: ExploreSearchCriteria(
                maxTotalTime: filters.totalTime,
                servings: filters.servings,
                tagId: filters.tagId,
                sort: sort),
            page: page,
            size: 14)
        { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 처음 불러올 때, 목록에 보여줄 레시피가 하나도 없는 경우
                    if self.viewState == .initialLoading, response.content.isEmpty {
                        self.pagedRecipes = .initial
                        self.viewState = .empty
                        break
                    }
                    
                    self.pagedRecipes.appendPage(
                        response.content,
                        page: page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements
                    )
                    self.viewState = .loaded
                case .failure(let networkError):
                    if self.viewState == .initialLoading {
                        self.pagedRecipes = .initial
                        self.viewState = .error(message: networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                        self.viewState = .loaded
                    }
                }
                completion()
            }
        }
    }
    
    private func presentAddToPlanner(for id: Int64) {
        auth.performWhenLoggedIn {
            self.sheet = .addToPlanner(recipeId: id)
        }
    }
    
    private func handleReportRecipe(for recipe: CookableRecipe) {
        reportResource = ReportResource(
            id: recipe.id,
            authorId: recipe.authorId,
            authorUsername: recipe.authorUsername,
            type: .RECIPE,
            content: recipe.title)
    }
    
    /// 특정 레시피의 저장 상태를 토글합니다.
    private func toggleSave(of id: Int64) {
        // 관련 UI를 낙관적 업데이트 처리합니다.
        var isSaved = false
        pagedRecipes.updateItem(for: id) { recipe in
            recipe.savedByUser.toggle()
            isSaved = recipe.savedByUser
        }
        
        pendingSaveRecipeIds.insert(id)
        
        let completionHandler: (Result<Empty, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.pendingSaveRecipeIds.remove(id)
                
                /**
                 '낙관적 UI 업데이트' 이후, 서버 응답이 돌아오기까지의 시간 동안 전역 인증 상태 변경(예: 게스트 -> 로그인)으로 인해 `items` 전체가 교체될 수 있습니다.
                 따라서 API 호출 전에 계산했던 `index`는 더 이상 유효하지 않을 수 있으므로, 실제 데이터를 업데이트하기 직전에 반드시 최신 `items` 배열을 기준으로 `index`를 다시 조회해야 합니다. (`Paged.updateItem`)
                 */
                
                if case .failure(let networkError) = result {
                    self.alert = .error(message: networkError.userMessage)
                    self.pagedRecipes.updateItem(for: id) { recipe in recipe.savedByUser.toggle() } // 낙관적 업데이트된 UI 상태를 롤백합니다.
                }
            }
        }
        
        if isSaved { userService.saveRecipe(for: id, completion: completionHandler) }
        else { userService.unsaveRecipe(for: id, completion: completionHandler) }
    }
    
    /// 특정 레시피의 좋아요 상태를 토글합니다.
    private func toggleLike(of id: Int64) {
        // 관련 UI를 낙관적 업데이트 처리합니다.
        var isLiked = false
        pagedRecipes.updateItem(for: id) { recipe in
            recipe.likedByUser.toggle()
            isLiked = recipe.likedByUser
            recipe.likedCount = isLiked ? (recipe.likedCount + 1) : (recipe.likedCount - 1)
        }
        
        pendingLikeRecipeIds.insert(id)
        
        let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.pendingLikeRecipeIds.remove(id)
            
            /**
             '낙관적 UI 업데이트' 이후, 서버 응답이 돌아오기까지의 시간 동안 전역 인증 상태 변경(예: 게스트 -> 로그인)으로 인해 `items` 전체가 교체될 수 있습니다.
             따라서 API 호출 전에 계산했던 `index`는 더 이상 유효하지 않을 수 있으므로, 실제 데이터를 업데이트하기 직전에 반드시 최신 `items` 배열을 기준으로 `index`를 다시 조회해야 합니다. (`Paged.updateItem`)
             */
            
            switch result {
            case .success(let response):
                self.pagedRecipes.updateItem(for: id) { recipe in
                    recipe.likedByUser = response.liked
                    recipe.likedCount = response.count
                }
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
                self.pagedRecipes.updateItem(for: id) { recipe in
                    recipe.likedByUser.toggle()
                    isLiked = recipe.likedByUser
                    recipe.likedCount = isLiked ? (recipe.likedCount + 1) : (recipe.likedCount - 1)
                }
            }
        }

        if isLiked { likeService.likeRecipe(for: id, completion: completionHandler) }
        else { likeService.unlikeRecipe(for: id, completion: completionHandler) }
    }
    
    private func resetListState() {
        pagedRecipes = .initial
        pendingSaveRecipeIds.removeAll()
        pendingLikeRecipeIds.removeAll()
    }
    
    private func index(of recipeId: Int64) -> Int? {
        pagedRecipes.items.firstIndex(where: { $0.id == recipeId })
    }
}

enum ExploreRecipesSheet: Identifiable {
    case addToPlanner(recipeId: Int64)
    
    var id: String {
        switch self {
        case .addToPlanner(let recipeId): return "addToPlanner-\(recipeId)"
        }
    }
}

enum ExploreRecipesViewState: Equatable {
    case initialLoading
    case loaded
    case empty
    case error(message: String)
}
