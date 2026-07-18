//
//  ExploreViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import SwiftUI
import Combine

class ExploreViewModel: ObservableObject {
    /// 검색 모드 활성화 여부를 결정합니다.
    ///
    /// - `true`: 검색 결과 화면인 `ExploreSearchListView`을 보여줍니다.
    /// - `false`: 카테고리 탐색 화면인 `ExploreCategoryListView`을 보여줍니다.
    @Published var isSearchMode: Bool = false
    
    /// 입력된 키워드입니다.
    ///
    /// - 값 변경이 감지되면, `searchCriteriaPublisher`를 구독하는 모든 뷰 모델로 이벤트를 발행함으로써, 관련 API 호출을 트리거합니다.
    /// - API 요청 시 레시피 검색 조건으로 사용하는 데이터 소스입니다.
    /// - ExploreSearchBar의 `keyword`와 binding 됩니다.
    /// - 동작 흐름:
    ///    1. ExploreSearchBar를 통해 키워드가 입력되면, 이 프로퍼티의 값이 변경됩니다.
    ///    2. 입력이 일정 시간 동안 멈추면, 변경된 값이 `searchCriteriaPublisher`를 통해 SearchListViewModel 등의 하위 뷰 모델로 전파됩니다.
    ///    3. 하위 뷰 모델이 신호를 받으면, 키워드로 검색 API를 호출합니다.
    @Published var keyword: String = ""
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ExploreAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: ExploreSheet?
    
    @Published var reportResource: ReportResource?
    
    /// 적용된 필터 옵션 모음입니다. (최대 소요 시간, 제공량, 카테고리 ID 등)
    ///
    /// - 값 변경이 감지되면, `searchCriteriaPublisher`를 구독하는 모든 뷰 모델로 이벤트를 발행함으로써, 관련 API 호출을 트리거합니다.
    /// - 필터 옵션 별 값 설정 방식:
    ///     1. 최대 소요 시간, 제공량: ServingsPicker 또는 TotalTimePicker를 통해 선택된 값을 바로 설정합니다.
    ///     2. 카테고리 ID: ThemePickerView를 통해 `commonCategory`가 변경되면, `didSet`을 통해 해당 카테고리의 ID만 추출 후 자동으로 설정됩니다.
    /// - API 요청 시 레시피 조회/검색 조건으로 사용하는 데이터 소스입니다. 현재 선택된 카테고리는 `commonCategory`도 가지고 있지만, API 요청 시에 필요한 '현재 선택된 카테고리의 ID'를 별도로 가집니다.
    @Published var commonFilters = ExploreFilters()
    
    /// 선택된 정렬 기준입니다.
    ///
    /// - 값 변경이 감지되면, `searchCriteriaPublisher`를 구독하는 모든 뷰 모델로 이벤트를 발행함으로써, 관련 API 호출을 트리거합니다.
    /// - API 요청 시 레시피 조회/검색 조건으로 사용하는 데이터 소스입니다.
    @Published var commonSort: ExploreRecipesSort = .TRENDING
    
    /// 선택된 카테고리입니다.
    ///
    /// - 현재 선택된 카테고리 이름을 ExploreSearchBar를 통해 보여주기 위해 사용합니다.
    /// - ExploreView 내 API 요청 시 필요한 `commonFilterOptions`의 카테고리 ID `categoryId`와 값을 동기화할 때 사용합니다.
    ///     - 카테고리는 ExploreView가 present하는 ThemePickerView를 통해서만 선택할 수 있습니다.
    ///       이때 ThemePickerView는 `ExploreCategoryItem`이라는 자체 타입으로 선택된 카테고리 정보를 반환합니다.
    ///       그런데, API를 요청할 때에는 카테고리의 ID만을 포함하는 필터 옵션 `commonFilterOptions`를 사용하기 때문에,
    ///       새 카테고리를 선택함과 동시에 `commonFilterOptions.categoryId`의 값도 새로 설정합니다.
    @Published var commonTag: ExploreTagItem? = nil {
        didSet {
            var newFilters = self.commonFilters
            newFilters.tagId = commonTag?.id
            commonFilters = newFilters
        }
    }
    
    @Published var navigationRoute: ViewRoute?
    
    /// 사용자가 선택할 수 있는 정렬 옵션입니다.
    var selectableSortOptions: [ExploreRecipesSort] = ExploreRecipesSort.allCases
    
    /// 레시피 조회/검색 조건(키워드, 카테고리, 필터, 정렬) 중 하나라도 변경되면, 이를 감지했다는 신호를 publish 합니다.
    ///
    /// - 모든 조건을 하나로 묶어(CombineLatest) 하위 뷰 모델에 전달합니다.
    /// - `ExploreSearchListViewModel`, `ExploreCategoryListViewModel`에서 이 값을 구독하여, 변경된 조건으로 API를 호출할 수 있습니다.
    /// - 키워드에는 `debounce`를 적용하여 과도한 검색 요청을 방지합니다.
    /// - `removeDuplicates`를 통해 이전과 동일한 조건일 경우 이벤트를 무시합니다.
    var searchCriteriaPublisher: AnyPublisher<(String, ExploreFilters, ExploreRecipesSort), Never> {
        // searchText에 타이핑 지연(debounce)을 적용합니다.
        let debouncedSearchKeyword = $keyword
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .prepend(keyword)
        
        // 필터나 정렬 조건에는 debounce를 적용하지 않습니다.
        return debouncedSearchKeyword
            .combineLatest($commonFilters, $commonSort)
            .map { ($0, $1, $2) } // 4개의 Publisher를 하나의 튜플로 묶습니다.
            .removeDuplicates { prev, current in
                // 이전과 모든 기준이 동일하면 이벤트를 발행하지 않습니다.
                return prev.0 == current.0 && prev.1 == current.1 && prev.2 == current.2
            }
            .eraseToAnyPublisher()
    }
    
    private let auth: AuthProvider
    private let tagService = TagService.shared
    private let recipeService = RecipeService.shared
    
    init(auth: AuthProvider = AuthManager.shared) {
        self.auth = auth
    }
    
    func loadTag(id: Int64) {
        tagService.fetchTagBasic(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let tag): self.commonTag = tag
                case .failure(let failure): print("[ExploreViewModelN2.loadTag] 태그 정보를 불러오지 못했어요: \(failure.userMessage)")
                }
            }
        }
    }
    
    func presentCalendar(of id: Int64) {
        auth.performWhenLoggedIn {
            self.sheet = .plannerDatePicker(recipeId: id)
        }
    }
    
    func navigateToRecipe(of recipe: ExploreRecipe) {
        navigationRoute = .recipe(id: recipe.id)
    }

    private func handleReportRecipe(of recipe: CookableRecipe) {
        self.alert = .report(recipeTitle: recipe.title)
    }
}

enum ExploreAlert: Identifiable {
    case report(recipeTitle: String)
    case addedToPlanner(recipeTitle: String)
    case error(message: String)
    
    var id: String {
        switch self {
        case .report: return "report"
        case .addedToPlanner: return "addedToPlanner"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .report(let recipeTitle):
            return Alert(
                title: Text("레시피 신고 완료"),
                message: Text("'\(recipeTitle.truncated())' 레시피 신고 접수가 완료됐어요."),
                dismissButton: .default(Text("확인"))
            )
        case .addedToPlanner(let recipeTitle):
            return Alert(
                title: Text("플래너에 추가 완료"),
                message: Text("'\(recipeTitle.truncated())' 레시피를 플래너에 추가했어요."),
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

enum ExploreSheet: Identifiable {
    case tagsPicker
    case totalTimePicker
    case servingsPicker
    case plannerDatePicker(recipeId: Int64)
    
    var id: String {
        switch self {
        case .tagsPicker: return "tagsPicker"
        case .totalTimePicker: return "totalTimePicker"
        case .servingsPicker: return "servingsPicker"
        case .plannerDatePicker(let recipeId): return "plannerDatePicker-\(recipeId)"
        }
    }
}

struct ExploreFilters: Equatable, Codable, Hashable {
    var totalTime: Int?
    var servings: Int?
    var tagId: Int64?
}
