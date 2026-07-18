//
//  CookableRecipeListViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/5/25.
//

import SwiftUI
import Combine
import Alamofire

@MainActor
class CookableRecipeListViewModel: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    @Published var viewState: CookableRecipeListViewState = .initialLoading
    
    @Published var reportResource: ReportResource?
    
    @Published var pagedRecipes: Paged<CookableRecipe> = .initial
    @Published var sort: CookableRecipeSort
    @Published var searchCriteria: CookableSearchCriteria
    
    @Published var showNavigationBarTitle = false
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: CookableRecipeListAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: CookableRecipeListSheet?
    
    @Published var togglingSaveIds: Set<Int64> = []
    
    /// 현재 사용자
    /// - 로그인 상태가 아니면 `nil`이 됩니다.
    @Published var currentUser: CurrentUser?
    
    private let auth: AuthProvider
    
    private var cancellables = Set<AnyCancellable>()
    private var recipesRequestId: UUID?
    
    var selectableSortOptions: [CookableRecipeSort] {
        let sorts = CookableRecipeSort.allCases
        return auth.isLoggedIn ? sorts : sorts.filter( { $0 != .FEWEST_MISSING_REQUIREMENTS } )
    }
    
    var navigationTitleLabel: String {
        let count = pagedRecipes.totalElements
        return 0 < count ? "\(count)개의 레시피" : "레시피"
    }
    
    init(searchCriteria: CookableSearchCriteria, auth: AuthProvider = AuthManager.shared) {
        self.searchCriteria = searchCriteria
        self.auth = auth
        self.sort = auth.isLoggedIn ? .FEWEST_MISSING_REQUIREMENTS : .TRENDING
        
        subscribeToSelectedSort()
        subscribeToSearchCriteria()
    }
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    ///
    /// 로그인 사용자가 변경되었거나 화면에 표시 중인 데이터가 없는 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if case .loaded = viewState, currentUser == auth.currentUser { return }
        resetAndLoadAll()
    }
    
    func setupForLoad() {
        currentUser = auth.currentUser
        togglingSaveIds.removeAll()
        recipesRequestId = UUID()
        pagedRecipes = .initial
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우: Ex. 정렬 옵션 변경 시
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    func resetAndLoadAll() {
        viewState = .initialLoading
        
        setupForLoad()
        loadRecipes(page: 0)
    }
    
    func refresh() async {
        setupForLoad()
        await withCheckedContinuation { continuation in
            self.loadRecipes(page: 0, completion: continuation.resume)
        }
    }
    
    private func subscribeToSelectedSort() {
        $sort
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resetAndLoadAll()
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSearchCriteria() {
        $searchCriteria
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // 0.3초 지연
            .sink { [weak self] _ in
                self?.resetAndLoadAll()
            }
            .store(in: &cancellables)
    }
}

extension CookableRecipeListViewModel {
    func handleRecipeAction(for item: CookableRecipe, action: CookableRecipeItemAction) {
        switch action {
        case .save: toggleSave(for: item)
        case .addToPlanner: presentCalendar(for: item.id)
        case .report: handleReportRecipe(for: item)
        }
    }
    
    func loadMoreRecipes() {
        guard viewState != .initialLoading,
                !pagedRecipes.isLoadingNextPage,
                pagedRecipes.hasNextPage else { return }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            pagedRecipes.isLoadingNextPage = true
            loadRecipes(page: pagedRecipes.page + 1) {
                self.pagedRecipes.isLoadingNextPage = false
            }
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
    
    func presentCalendar(for id: Int64) {
        auth.performWhenLoggedIn {
            self.sheet = .addToPlanner(recipeId: id)
        }
    }
    
    private func loadRecipes(page: Int, completion: @escaping () -> Void = {}) {
        let requestID = recipesRequestId ?? UUID()
        recipesRequestId = requestID
        
        RecipeService.shared.fetchTodayCookableList(searchCriteria: searchCriteria, sort: sort, size: 10, page: page) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                guard self.recipesRequestId == requestID else {
                    completion()
                    return
                }
                
                switch result {
                case .success(let result):
                    if result.totalElements == 0 && page == 0 {
                        self.pagedRecipes = .initial
                        self.viewState = .empty
                        break
                    }
                    
                    self.pagedRecipes.appendPage(
                        result.content,
                        page: result.page,
                        hasNextPage: result.hasNext,
                        totalElements: result.totalElements)
                    
                    self.viewState = .loaded
                case .failure(let networkError):
                    print(networkError)
                    if self.viewState == .initialLoading {
                        self.viewState = .error(message: networkError.userMessage)
                    } else {
                        self.viewState = .loaded
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
                completion()
            }
        }
    }
    
    private func toggleSave(for item: CookableRecipe) {
        guard !togglingSaveIds.contains(item.id) else { return }
        togglingSaveIds.insert(item.id)
        
        var saved = false
        
        pagedRecipes.updateItem(for: item.id) { recipe in
            recipe.savedByUser.toggle()
            saved = recipe.savedByUser
        }
        
        let completionHandler: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
            if case .failure(let networkError) = result {
                self?.alert = .error(message: networkError.userMessage)
                self?.pagedRecipes.updateItem(for: item.id) { recipe in recipe.savedByUser.toggle() }
            }
            self?.togglingSaveIds.remove(item.id)
        }
        
        if saved { UserService.shared.saveRecipe(for: item.id, completion: completionHandler) }
        else { UserService.shared.unsaveRecipe(for: item.id, completion: completionHandler) }
    }
}

enum CookableRecipeListSheet: Identifiable {
    case addToPlanner(recipeId: Int64)
    
    var id: String {
        switch self {
        case .addToPlanner(let recipeId): return "addToPlanner-\(recipeId)"
        }
    }
}

enum CookableRecipeListAlert: Identifiable {
    case addedToPlanner(title: String)
    case error(message: String)
    
    var id: String {
        switch self {
        case .addedToPlanner: return "addedToPlanner"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .addedToPlanner(let title):
            return Alert(
                title: Text("플래너에 추가 완료"),
                message: Text("'\(title.truncated())' 레시피를 플래너에 추가했어요."),
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

enum CookableRecipeListViewState: Equatable {
    case initialLoading
    case loaded
    case error(message: String)
    case empty
}
