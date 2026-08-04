//
//  ExploreRecipeSearchViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import SwiftUI
import Combine
import Alamofire

@MainActor
class ExploreRecipeSearchViewModel: ObservableObject {
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: ExploreRecipeSearchViewState = .idle
    
    @Published var pagedRecipes: Paged<ExploreRecipe> = .initial

    @Published var navigationRoute: ViewRoute?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: ExploreRecipesSheet?
    
    @Published var reportResource: ReportResource?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ExploreAlert?
    
    @Published var pendingLikeRecipeIds: Set<Int64> = []
    @Published var pendingSaveRecipeIds: Set<Int64> = []
    
    /// 현재 검색 관련 프로퍼티들의 컨텍스트입니다.
    ///
    /// 유효한 검색 조건이 갖춰져 있는지 확인한 후, 유효한 경우 튜플 타입으로 반환합니다.
    private var searchContext: (filters: ExploreFilters, sort: ExploreRecipesSort, keyword: String)? {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let filters = filters, let sort = sort, !trimmedKeyword.isEmpty
        else {
            return nil
        }
        
        return (filters, sort, trimmedKeyword)
    }

    private var keyword: String = ""
    private var filters: ExploreFilters?
    private var sort: ExploreRecipesSort?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let auth: AuthProvider
    private let userService = UserService.shared
    private let recipeService = RecipeService.shared
    private let likeService = RecipeLikeService.shared
    
    /// 검색 요청 ID입니다.
    ///
    /// - 유효한 검색 요청만 남겨야 할 때 사용합니다.
    /// - 기존 키워드에 대한 검색 응답을 받기 전에 키워드를 변경했으나,
    ///   기존 검색어에 대한 응답이 늦게 도착해 현재 키워드에 대한 검색 응답이 무시되는 문제를 방지합니다.
    private var searchRequestId: UUID?
    
    /// 가장 최근에 데이터를 불러온 시점의 사용자 ID입니다.
    ///
    /// 데이터가 어떤 사용자를 기준으로 불러와졌는지 확인할 때 사용할 수 있습니다.
    private var lastLoadedUserId: Int64?
   
    /// 생성자입니다.
    ///
    /// - Parameters:
    ///   - searchCriteriaPublisher:ExploreViewModel로부터 레시피 목록 조회 또는 검색 관련 조건 변경 이벤트를 전달받기 위해 사용합니다.
    ///
    /// 이 뷰 모델은 API 호출 시, 값 변경이 빈번하고 동시다발적으로 일어나는 키워드인 `keyword`도 사용합니다.
    /// 필터 옵션/정렬과 달리, `keyword`는 사용자가 타이핑할 때마다 실시간 수준으로 변경이 발생하는 속성을 가집니다.
    /// 이때, 모든 변경마다 API를 호출하는 건 비효율적입니다.
    ///
    /// ExploreViewModel은 `keyword`에 대한 지연 처리 뿐 아니라 `filter`, `sort`까지 하나로 묶어서 신호를 줍니다.
    /// 그래서 뷰에서 `.task`를 사용하지 않고, 키워드 입력이 일정 시간 멈췄을 때에만 요청에 필요한 데이터를 하나로 묶어서 API를 호출하기 위해 Combine을 사용합니다.
    init(
        auth: AuthProvider = AuthManager.shared,
        searchCriteriaPublisher: AnyPublisher<(String, ExploreFilters, ExploreRecipesSort), Never>
    ) {
        self.auth = auth
        
        // ExploreViewModel로부터 검색 조건이 변경되었다는 신호를 구독합니다.
        searchCriteriaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (keyword, filters, sort) in
                guard let self = self else { return }
                self.keyword = keyword
                self.filters = filters
                self.sort = sort
                
                self.resetAndLoadAll()
            }
            .store(in: &cancellables)
    }
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    ///
    /// - 뷰의 진입점 역할을 합니다.
    /// - `viewState`가 `idle`(키워드 입력 대기) 상태가 아니고, 로그인 사용자가 변경되었거나 화면에 표시 중인 데이터가 없는 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if case .loaded = viewState, lastLoadedUserId == auth.currentUser?.id { return }
        if case .idle = viewState { return }
        resetAndLoadAll()
    }
    
    func refresh() async {
        guard searchContext != nil else {
            resetToIdle()
            return
        }
        
        setupForLoad()
        await withCheckedContinuation { continuation in
            self.searchRecipes(page: 0, completion: continuation.resume)
        }
    }
    
    private func setupForLoad() {
        lastLoadedUserId = auth.currentUser?.id
        searchRequestId = UUID()
        resetPendingStates()
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우: Ex. 필터, 정렬 옵션 또는 검색어 변경 시
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    private func resetAndLoadAll() {
        guard searchContext != nil else {
            resetToIdle()
            return
        }
        
        viewState = .initialLoading
        pagedRecipes = .initial
        
        setupForLoad()
        searchRecipes(page: 0)
    }
    
    /// 뷰, 뷰 모델의 상태를 초기화합니다.
    ///
    /// 검색을 완전히 취소하거나, 예상치 못한 오류로 인해 검색 초기 화면을 보여주기 위해 사용합니다.
    private func resetToIdle() {
        resetPendingStates()
        keyword = ""
        viewState = .idle
    }
}

extension ExploreRecipeSearchViewModel {
    func loadMoreRecipes() {
        guard viewState == .loaded,
              pagedRecipes.hasNextPage,
              !pagedRecipes.isLoadingNextPage
        else { return }
        pagedRecipes.isLoadingNextPage = true
        
        Task { [weak self] in // self를 약하게 잡아, View가 화면에서 사라지는 상황 등이 발생하면 불러오기를 취소합니다.
            guard let self = self else { return }
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            searchRecipes(page: pagedRecipes.page + 1) { [weak self] in
                self?.pagedRecipes.isLoadingNextPage = false
            }
        }
    }
    
    func handleItem(for recipe: ExploreRecipe, action: ExploreRecipeItemAction) {
        switch action {
        case .save: toggleSave(for: recipe)
        case .like: toggleLike(for: recipe)
        case .comment: navigationRoute = .comment(recipeId: recipe.id)
        case .addToPlanner: presentAddToPlanner(for: recipe.id)
        case .report: handleReportRecipe(for: recipe)// TODO: 신고
        }
    }
    
    /// 검색 API을 호출해서 가져왔던 기존 리스트 데이터만 모두 비웁니다. 키워드를 포함한 검색 조건은 유지됩니다.
    private func resetPendingStates() {
        pendingSaveRecipeIds.removeAll()
        pendingLikeRecipeIds.removeAll()
    }
    
    private func presentAddToPlanner(for id: Int64) {
        auth.performWhenLoggedIn {
            self.sheet = .addToPlanner(recipeId: id)
        }
    }
    
    /// 특정 레시피의 저장 상태를 토글합니다.
    private func toggleSave(for recipe: ExploreRecipe) {
        auth.performWhenLoggedIn {
            guard !self.pendingSaveRecipeIds.contains(recipe.id) else { return }
            
            // 관련 UI를 낙관적 업데이트 처리합니다.
            var saved = false
            self.pagedRecipes.updateItem(for: recipe.id) { recipe in
                recipe.savedByUser.toggle()
                saved = recipe.savedByUser
            }
            
            self.pendingSaveRecipeIds.insert(recipe.id)
            
            let completionHandler: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
                guard let self = self else { return }
                self.pendingSaveRecipeIds.remove(recipe.id)
                
                /**
                 '낙관적 UI 업데이트' 이후, 서버 응답이 돌아오기까지의 시간 동안 전역 인증 상태 변경(예: 게스트 -> 로그인)으로 인해 `items` 전체가 교체될 수 있습니다.
                 따라서 API 호출 전에 계산했던 `index`는 더 이상 유효하지 않을 수 있으므로, 실제 데이터를 업데이트하기 직전에 반드시 최신 `items` 배열을 기준으로 `index`를 다시 조회해야 합니다. (`Paged.updateItem`)
                 */
                
                if case .failure(let networkError) = result {
                    self.alert = .error(message: networkError.userMessage)
                    self.pagedRecipes.updateItem(for: recipe.id) { recipe in recipe.savedByUser.toggle() } // 낙관적 업데이트된 UI 상태를 롤백합니다.
                }
            }
            
            if saved { self.userService.saveRecipe(for: recipe.id, completion: completionHandler) }
            else { self.userService.unsaveRecipe(for: recipe.id, completion: completionHandler) }
        }
    }
    
    /// 특정 레시피의 좋아요 상태를 토글합니다.
    private func toggleLike(for recipe: ExploreRecipe) {
        auth.performWhenLoggedIn {
            guard !self.pendingLikeRecipeIds.contains(recipe.id) else { return }
            
            // 관련 UI를 낙관적 업데이트 처리합니다.
            var liked = false
            self.pagedRecipes.updateItem(for: recipe.id) { recipe in
                recipe.likedByUser.toggle()
                liked = recipe.likedByUser
                recipe.likedCount = liked ? (recipe.likedCount + 1) : (recipe.likedCount - 1)
            }
            
            self.pendingLikeRecipeIds.insert(recipe.id)
            
            let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
                guard let self = self else { return }
                self.pendingLikeRecipeIds.remove(recipe.id)
                
                /**
                 '낙관적 UI 업데이트' 이후, 서버 응답이 돌아오기까지의 시간 동안 전역 인증 상태 변경(예: 게스트 -> 로그인)으로 인해 `items` 전체가 교체될 수 있습니다.
                 따라서 API 호출 전에 계산했던 `index`는 더 이상 유효하지 않을 수 있으므로, 실제 데이터를 업데이트하기 직전에 반드시 최신 `items` 배열을 기준으로 `index`를 다시 조회해야 합니다. (`Paged.updateItem`)
                 */
                
                switch result {
                case .success(let response):
                    self.pagedRecipes.updateItem(for: recipe.id) { recipe in
                        recipe.likedByUser = response.liked
                        recipe.likedCount = response.count
                    }
                case .failure(let networkError):
                    self.alert = .error(message: networkError.userMessage)
                    self.pagedRecipes.updateItem(for: recipe.id) { recipe in
                        recipe.likedByUser.toggle()
                        liked = recipe.likedByUser
                        recipe.likedCount = liked ? (recipe.likedCount + 1) : (recipe.likedCount - 1)
                    }
                }
            }

            if liked { self.likeService.likeRecipe(for: recipe.id, completion: completionHandler) }
            else { self.likeService.unlikeRecipe(for: recipe.id, completion: completionHandler) }
        }
    }
    
    private func handleReportRecipe(for recipe: ExploreRecipe) {
        auth.performWhenLoggedIn {
            self.reportResource = ReportResource(
                id: recipe.id,
                authorId: recipe.authorId,
                authorUsername: recipe.authorUsername,
                type: .RECIPE,
                content: recipe.title)
        }
    }
    
    /// 특정 페이지에 대한 검색 API를 호출합니다.
    private func searchRecipes(page: Int, completion: @escaping () -> Void = {}) {
        guard let context = searchContext else {
            resetToIdle()
            completion()
            return
        }
        
        let requestId = UUID()
        searchRequestId = requestId
        
        recipeService.fetchExploreRecipes(
            searchCriteria: ExploreSearchCriteria(
                keyword: context.keyword,
                maxTotalTime: context.filters.totalTime,
                servings: context.filters.servings,
                tagId: context.filters.tagId,
                sort: context.sort
            ),
            page: page,
            size: 14) { [weak self] result in
                guard let self = self else { completion(); return }
                guard self.searchRequestId == requestId else { completion(); return } // 유효한 검색 요청인지 확인합니다.
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        // 처음 불러올 때, 목록에 보여줄 레시피가 하나도 없는 경우
                        if self.viewState == .initialLoading && response.content.isEmpty {
                            self.viewState = .empty(keyword: self.keyword)
                            self.pagedRecipes = .initial
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
    
    private func index(of recipeId: Int64) -> Int? {
        pagedRecipes.items.firstIndex(where: { $0.id == recipeId })
    }
    
}

enum ExploreRecipeSearchViewState: Equatable {
    case idle
    case initialLoading
    case loaded
    case empty(keyword: String)
    case error(message: String)
}
