////
////  RatingViewModel.swift
////  EATZ-Client-AppleSilicon
////
////  Created by 손원희 on 5/25/25.
////
//
//import SwiftUI
//import Combine
//
///// RatingView에서 필요한 데이터와 로직을 제공합니다.
//@MainActor
//class RatingViewModel: ObservableObject {
//    // MARK: - 공개 프로퍼티 (Public Properties)
//    
//    /// 평가가 존재하지 않는지에 대한 여부
//    /// - 뷰가 최상위로 어떤 서브뷰를 화면에 보여줄지 결정하기 위해 사용합니다.
//    @Published var isEmptyState: Bool = false
//    
//    /// 레시피 필수 정보
//    @Published var recipeEssential: RecipeEssentialWithAuthor? {
//        didSet {
//            // 레시피 필수 정보 불러오기 완료 시, 기존 평가 목록 내 모든 항목 권한도 다시 업데이트합니다.
//            if !pagedRatings.isEmpty { updateRatingsPermissions() }
//        }
//    }
//    
//    /// 평가 요약 상태
//    @Published var indicatorState: RatingIndicatorState = .initialLoading
//    
//    /// 내 평가 상태
//    @Published var myRatingState: RatingMyState = .initialLoading
//    
//    /// 평가 목록
//    @Published var pagedRatings: Paged<RatingWithPermissions> = .initial {
//        didSet {
//            isEmptyState = pagedRatings.isEmpty
//        }
//    }
//    
//    /// 화면에 표시할 fullScreenCover
//    /// - 아무 fullScreenCover도 표시하지 않는 경우 `nil`이 됩니다.
//    @Published var fullScreenCover: RatingFullScreenCover?
//    
//    /// 화면에 표시할 alert
//    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
//    @Published var alert: RatingAlert?
//    
//    var navigationTitleLabel: String {
//        if 0 < pagedRatings.totalElements { return "\(pagedRatings.totalElements)개의 평가" }
//        return "평가"
//    }
//    
//    var authManager: AuthManager? {
//        didSet {
//            currentUser = authManager?.currentUser
//        }
//    }
//    
//    // MARK: - 비공개 프로퍼티 (Private Properties)
//    
//    /// 현재 보고 있는 레시피의 ID
//    private let recipeId: Int64
//    
//    /// 현재 사용자
//    private var currentUser: CurrentUser? {
//        didSet {
//            updateRatingsPermissions()
//        }
//    }
//    
//    // MARK: - 의존성 (Dependencies)
//    
//    private let userService = UserService.shared
//    private let recipeService = RecipeService.shared
//    private let ratingService = RatingService.shared
//    
//    // MARK: - 초기화 (Initialization)
//    
//    init(for recipeId: Int64) {
//        self.recipeId = recipeId
//    }
//    
//    // MARK: - 공개 메서드 (Public Methods)
//    
//    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
//    /// - 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
//    /// - 기존 불러온 데이터를 화면에 표시 중인지, 사용자가 이전과 동일한지 확인한 후,
//    ///   화면에 표시 중인 데이터가 없거나 사용자가 변경된 경우에만 `resetAndLoadAll()`을 호출합니다.
//    func prepareDataIfNeeded() {
//        if !validateContext() { return }
//        resetAndLoadAll()
//    }
//    
//    func refresh() async {
//        await withCheckedContinuation { continuation in
//            self.loadAll(completion: continuation.resume)
//        }
//    }
//    
//    // MARK: - 비공개 메서드 (Private Methods)
//    
//    private func loadAll(completion: @escaping () -> Void = {}) {
//        loadRecipeEssential()
//        loadRatingSummary { [weak self] hasRatings in
//            guard let self = self else { return }
//            
//            if hasRatings {
//                if currentUser != nil { self.loadMyRating() }
//                else { self.myRatingState = .l }
//                self.loadPagedRatings(completion: completion)
//            } else {
//                self.myRatingState = .loadedNothing
//                self.pagedRatings = .initial
//                completion()
//            }
//        }
//    }
//    
//    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티의 상태를 초기화하고, 필요한 모든 데이터를 불러옵니다.
//    ///
//    /// 아래와 같은 경우에 사용합니다.
//    /// - 화면에 표시해야 할 데이터가 필요한 경우
//    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
//    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
//    private func resetAndLoadAll() {
//        indicatorState = .initialLoading
//        if pagedRatings.isEmpty {
//            myRatingState = .initialLoading
//            pagedRatings = .initial
//        }
//        
//        loadAll()
//    }
//    
//    /// 데이터를 불러올 필요성을 검증합니다.
//    /// - Returns:
//    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
//    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
//    private func validateContext() -> Bool {
//        if case .loaded = indicatorState, !pagedRatings.isEmpty { return false }
//        return true
//    }
//}
//
//extension RatingViewModel {
//    func presentEditorView(mode: RatingEditorModeOld) {
//        authManager?.performWhenLoggedIn {
//            self.fullScreenCover = .ratingEditor(
//                recipeId: self.recipeId,
//                mode: mode
//            )
//        }
//    }
//    
//    func hideRating(for id: Int64) {
//        print("hide rating \(id)")
//    }
//    
//    func handleDelete(type: RatingDeleteActionType) {
//        authManager?.performWhenLoggedIn {
//            self.alert = .confirmDelete(
//                type: type,
//                confirmAction: {
//                    self.deleteRating(for: type.rating.id, isMine: type.isMine)
//                }
//            )
//        }
//    }
//    
//    /// 평가 목록을 끝까지 스크롤했을 때, 평가의 다음 페이지 데이터를 불러옵니다.
//    func loadMoreRatingList() {
//        // 다음 페이지가 있으며, 추가로 불러오는 중이 아닐 때만 다음 페이지를 요청합니다.
//        guard pagedRatings.hasNextPage, !pagedRatings.isLoadingNextPage else { return }
//        pagedRatings.isLoadingNextPage = true
//        
//        // 다음 페이지에 대한 댓글 목록을 요청합니다.
//        loadPagedRatings(page: pagedRatings.page + 1) {
//            self.pagedRatings.isLoadingNextPage = false
//        }
//    }
//    
//    private func loadRecipeEssential(onSuccess: @escaping () -> Void = {}) {
//        recipeService.fetchEssential(id: recipeId) { [weak self] result in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let recipeEssential):
//                    self.recipeEssential = recipeEssential
//                    onSuccess()
//                case .failure(let networkError):
//                    self.alert = .error(title: nil, message: networkError.userMessage)
//                }
//            }
//        }
//    }
//    
//    private func loadRatingSummary(onSuccess: ((Bool) -> Void)? = nil) {
//        recipeService.fetchRatingIndicator(for: recipeId) { [weak self] result in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let summary):
//                    self.indicatorState = .loaded(summary)
//                    let hasRatings = 0 < summary.summary.count
//                    self.isEmptyState = !hasRatings
//                    onSuccess?(hasRatings)
//                case .failure(let networkError):
//                    self.indicatorState = .error(message: networkError.userMessage)
//                    self.alert = .error(title: "평가 요약 불러오기 오류", message: networkError.userMessage)
//                }
//            }
//        }
//    }
//    
//    private func loadMyRating() {
//        recipeService.fetchMyRating(for: recipeId) { [weak self] result in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    guard let response = response else {
//                        self.myRatingState = .loadedNothing
//                        return
//                    }
//                    
//                    self.myRatingState = .loaded(response)
//                case .failure(let networkError):
//                    self.myRatingState = .error(message: networkError.userMessage)
//                    self.alert = .error(title: "내 평가 불러오기 오류", message: networkError.userMessage)
//                }
//            }
//        }
//    }
//    
//    private func loadPagedRatings(page: Int = 0, size: Int = 2, completion: @escaping (() -> Void) = {}) {
//        recipeService.fetchRatings(for: recipeId, page: page, size: size) { [weak self] result in
//            guard let self = self else { completion(); return }
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    let ratings = response.content
//                    let recipeAuthorId = self.recipeEssential?.authorId
//                    let newRatingsWithPermissions = ratings.map { rating in
//                        rating.toRatingWithPermissions(for: self.currentUser, recipeAuthorId: recipeAuthorId)
//                    }
//                    
//                    print("DBG | \(#function) 성공적으로 \(ratings.count)개의 평가 목록을 불러왔어요.")
//                    self.pagedRatings.appendPage(
//                        newRatingsWithPermissions,
//                        page: response.page,
//                        hasNextPage: response.hasNext,
//                        totalElements: response.totalElements)
//                case .failure(let networkError):
//                    if page == 0 { self.pagedRatings = .initial }
//                    self.alert = .error(title: "평가 목록 불러오기 오류", message: networkError.userMessage)
//                }
//                completion()
//            }
//        }
//    }
//    
//    /// 평가 목록의 평가 별 제어 권한을 업데이트합니다.
//    ///
//    /// 기존 `pagedRatings`의 원본 `Rating`을 바탕으로, 현재 로그인 사용자(`currentUser`)와
//    /// 레시피 작성자 ID(`recipeEssential.authorId`) 상태에 맞게 평가 별 제어 권한만 새롭게 계산 및 적용합니다.
//    private func updateRatingsPermissions() {
//        guard !pagedRatings.isEmpty else { return }
//        let ratingsWithPermissions = pagedRatings.items
//
//        pagedRatings.items = ratingsWithPermissions.map { ratingWithPermission in
//            let rating = ratingWithPermission.rating
//            guard let recipeAuthorId = recipeEssential?.authorId else {
//                return RatingWithPermissions(rating, permissions: [])
//            }
//            
//            return rating.toRatingWithPermissions(for: self.currentUser, recipeAuthorId: recipeAuthorId)
//        }
//    }
//    
//    private func deleteRating(for id: Int64, isMine: Bool) {
//        guard let index = pagedRatings.items.firstIndex(where: { $0.id == id }) else { return }
//        let rating = pagedRatings.items[index]
//        pagedRatings.remove(at: index)
//        
//        let previousMyRatingState = myRatingState
//        if isMine { myRatingState = .loadedNothing } // '평가 안 함' 상태로 낙관적 업데이트 처리합니다.
//        
//        ratingService.delete(for: id) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.loadRatingSummary(onSuccess: {_ in})
//                    self.alert = .deletionSuccess(isMine: isMine)
//                case .failure(let networkError):
//                    // 낙관적 업데이트된 항목을 롤백 처리합니다.
//                    self.pagedRatings.insert(rating, at: index)
//                    if isMine { self.myRatingState = previousMyRatingState }
//                    self.alert = .error(title: "평가 삭제 실패", message: networkError.userMessage)
//                }
//            }
//        }
//    }
//    
//    private func deleteRatingOld(for id: Int64, isMine: Bool) {
//        var removedIndex: Int?
//        var removedItem: RatingWithPermissions?
//        
//        if let index = self.pagedRatings.items.firstIndex(where: {$0.id == id}) {
//            removedIndex = index
//            removedItem = pagedRatings.items[index]
//            pagedRatings.remove(at: index)
//        }
//        
//        let previousMyRatingState = myRatingState
//        if isMine { myRatingState = .loadedNothing } // '평가 안 함' 상태로 낙관적 업데이트 처리합니다.
//        
//        recipeService.delete(for: id) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.loadRatingSummary(onSuccess: {_ in})
//                    self.alert = .deletionSuccess(isMine: isMine)
//                case .failure(let networkError):
//                    if let index = removedIndex, let item = removedItem {
//                        if index <= self.pagedRatings.items.count {
//                            self.pagedRatings.insert(item, at: index)
//                        }
//                    }
//                    if isMine { self.myRatingState = previousMyRatingState }
//                    self.alert = .error(title: "평가 삭제 실패", message: networkError.userMessage)
//                }
//            }
//        }
//    }
//}
//
//enum RatingDeleteActionType: Equatable, Identifiable {
//    case mine(rating: Rating)
//    case other(rating: Rating)
//    
//    var id: String {
//        switch self {
//        case .mine(let r): return "delete_mine_\(r.id)"
//        case .other(let r): return "delete_other_\(r.id)"
//        }
//    }
//    
//    var rating: Rating {
//        switch self {
//        case .mine(let rating), .other(let rating):
//            return rating
//        }
//    }
//    
//    var isMine: Bool {
//        if case .mine = self { return true }
//        return false
//    }
//}
//
//enum RatingIndicatorState: Equatable {
//    case initialLoading
//    case loaded(RatingIndicator)
//    case error(message: String)
//}
//
//enum MyRatingState: Equatable {
//    case initialLoading
//    case loaded(Rating)
//    case loadedNothing
//    case error(message: String)
//}
