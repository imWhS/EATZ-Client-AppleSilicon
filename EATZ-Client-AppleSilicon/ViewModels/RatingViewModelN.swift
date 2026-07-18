//
//  RatingViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/10/26.
//

import SwiftUI

class RatingViewModelN: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 메인 뷰 데이터인 특정 레시피의 평가 관련 데이터 상태
    ///
    /// - 뷰는 레시피 핵심 정보 `RecipeEssentialWithAuthor`, 평가 목록 `Paged<RatingWithPermissions>`을 메인 뷰 데이터로 사용합니다.
    /// - 메인 뷰 데이터를 필요로 하는 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 뷰가 화면에 표시할 최상위 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var state: RatingState = .initialLoading
    
    /// 평가 지표 `RatingIndicator` 상태
    /// - 평가 지표 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    @Published var indicatorState: RatingIndicatorState = .initialLoading
    
    /// 내 평가 `Rating` 상태
    /// - 내 평가 관련 서브뷰 등을 분기 처리하기 위해 사용합니다.
    @Published var myState: RatingMyState = .initialLoading
    
    /// 화면에 표시할 fullScreenCover
    /// - 아무 fullScreenCover도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var fullScreenCover: RatingFullScreenCover?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RatingAlert?
    
    /// 차단하려는 사용자
    @Published var blockTargetUser: UserEssential?
    
    @Published var reportResource: ReportResource?
    
    var navigationTitleLabel: String {
        if case .content(_, let pagedRatings) = state, 0 < pagedRatings.totalElements {
            return "\(pagedRatings.totalElements)개의 평가"
        } else {
            return "평가"
        }
    }
    
    /// 뷰 인스턴스 생성 시점에 필요한 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 뷰 최초 진입 시에만 메인 뷰 데이터를 불러옵니다.
    /// - 뷰의 인스턴스가 갓 만들어져서, 메인 뷰 데이터를 최초로 불러와야 할 때 사용할 수 있습니다.
    func loadInitial(for recipeId: Int64, _ currentUser: CurrentUser?) {
        // 메인 뷰 데이터 상태가 .initialLoading일 때만 동작합니다.
        guard case .initialLoading = state else { return }
        load(for: recipeId, currentUser)
    }
    
    /// 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 모든 뷰 상태 관련 프로퍼티를 `.initialLoading` 또는 `.idle`로 설정합니다.
    /// - 네트워크 오류 발생 등으로 인해 메인 뷰 데이터 상태가 `.error`일 떄, 메인 뷰 데이터 불러오기를 재시도 해야할 때 사용할 수 있습니다.
    func load(for recipeId: Int64, _ currentUser: CurrentUser?) {
        state = .initialLoading
        indicatorState = .initialLoading
        myState = .initialLoading
        
        loadAllSequentially(for: recipeId, currentUser)
    }
    
    /// 기존 불러온 적 있는 모든 뷰 데이터를 백그라운드에서 새로 고칩니다.
    ///
    /// 이미 존재하는 뷰 데이터를 그대로 화면에 표시하고 있는 상태에서 최신 뷰 데이터로 덮어써야 하는 경우에 사용할 수 있습니다.
    func refresh(for recipeId: Int64, _ currentUser: CurrentUser?) async {
        await withCheckedContinuation { continuation in
            loadAllSequentially(for: recipeId, currentUser, completion: continuation.resume)
        }
    }
}

extension RatingViewModelN {
    func presentEditor(for recipeId: Int64, mode: RatingEditorMode) {
        fullScreenCover = .ratingEditor(recipeId: recipeId, mode: mode)
    }
    
    func hideRating(for id: Int64) {
        print("hide rating \(id)")
    }
    
    func handleBlockUser(_ targetUser: UserEssential) {
        blockTargetUser = targetUser
    }
    
    func handleReportRating(for rating: Rating) {
        reportResource = ReportResource(
            id: rating.id,
            authorId: rating.author.id,
            authorUsername: rating.author.username,
            type: .RATING,
            content: rating.content)
    }
    
    func handleDelete(_ type: RatingDeleteActionType, _ recipeId: Int64) {
        alert = .confirmDelete(
            type: type,
            confirmAction: {
                self.deleteRating(for: type.rating.id, isMine: type.isMine, recipeId: recipeId)
            }
        )
    }
    
    /// 평가 목록의 평가 별 제어 권한을 업데이트합니다.
    ///
    /// 기존 `pagedRatings`의 원본 `Rating`을 바탕으로, 현재 로그인 사용자(`currentUser`)와
    /// 레시피 작성자 ID(`recipeEssential.authorId`) 상태에 맞게 평가 별 제어 권한만 새롭게 계산 및 적용합니다.
    func updateRatingsPermissions(currentUser: CurrentUser?) {
        guard case .content(let recipeEssential, var pagedRatingsWithPermissions) = state else { return }
        guard !pagedRatingsWithPermissions.isEmpty else { return }
        
        let ratings = pagedRatingsWithPermissions.items.map { return $0.rating }
        let ratingsWithPermissions = createRatingsWithPermissions(
            for: currentUser,
            from: ratings,
            recipeEssential.authorId)
        pagedRatingsWithPermissions.items = ratingsWithPermissions
        state = .content(recipeEssential, pagedRatingsWithPermissions)
    }
    
    func loadMoreRatings(currentUser: CurrentUser?, recipeId: Int64) {
        guard case .content(let recipeEssential, var pagedRatingsWithPermissions) = state else { return }
        guard pagedRatingsWithPermissions.hasNextPage, !pagedRatingsWithPermissions.isLoadingNextPage else { return }
        
        pagedRatingsWithPermissions.isLoadingNextPage = true
        state = .content(recipeEssential, pagedRatingsWithPermissions)
        
        loadPagedRatings(recipeId: recipeId, page: pagedRatingsWithPermissions.page + 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let newRatings = self.createRatingsWithPermissions(
                        for: currentUser,
                        from: response.content,
                        recipeEssential.authorId)
                    pagedRatingsWithPermissions.appendPage(
                        newRatings,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements)
                    self.state = .content(recipeEssential, pagedRatingsWithPermissions)
                case .failure(let networkError):
                    pagedRatingsWithPermissions.isLoadingNextPage = false
                    self.state = .content(recipeEssential, pagedRatingsWithPermissions)
                    self.alert = .error(title: "평가 목록 불러오기 오류", message: networkError.userMessage)
                }
            }
        }
    }
    
    private func handleSequentiallyErrors(_ sequentiallyErrors: [(error: NetworkError, message: String)]) -> Bool {
        if let error = sequentiallyErrors.first(where: { $0.error.isServiceUnavailable }) {
            state = .error(message: error.message)
            return false
        }
        
        if sequentiallyErrors.count == 1, let error = sequentiallyErrors.first {
            state = .error(message: error.1)
            return false
        }
        
        if 1 < sequentiallyErrors.count {
            state = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
            return false
        }
        
        return true
    }
    
    private func loadAllSequentially(for recipeId: Int64, _ currentUser: CurrentUser?, completion: (() -> Void)? = nil) {
        defer { completion?() }
        let group = DispatchGroup()
        var sequentiallyErrors: [(error: NetworkError, message: String)] = []
        
        var loadedRecipeEssential: RecipeEssentialWithAuthor? = nil
        var loadedRatingsPaged: RatingsPaged? = nil
        
        group.enter()
        loadRecipeEssential(recipeId: recipeId) { result in
            switch result {
            case .success(let recipeEssential): loadedRecipeEssential = recipeEssential
            case .failure(let networkError):
                sequentiallyErrors.append(Self.createSequentiallyError(from: networkError, "레시피 정보를 불러오지 못했어요."))
            }
            group.leave()
        }
        
        group.enter()
        loadPagedRatings(recipeId: recipeId, page: 0) { result in
            switch result {
            case .success(let ratingsPaged): loadedRatingsPaged = ratingsPaged
            case .failure(let networkError):
                sequentiallyErrors.append(Self.createSequentiallyError(from: networkError, "평가 목록을 불러오지 못했어요."))
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if !handleSequentiallyErrors(sequentiallyErrors) { return }
            
            guard let loadedRecipeEssential = loadedRecipeEssential,
                  let loadedRatingsPaged = loadedRatingsPaged else {
                state = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
                return
            }
            
            let loadedRatings = loadedRatingsPaged.content
            let ratingsWithPermissions = createRatingsWithPermissions(
                for: currentUser,
                from: loadedRatings,
                loadedRecipeEssential.authorId)
            
            var pagedRatingsWithPermissions: Paged<RatingWithPermissions> = .initial
            pagedRatingsWithPermissions.appendPage(
                ratingsWithPermissions,
                page: loadedRatingsPaged.page,
                hasNextPage: loadedRatingsPaged.hasNext,
                totalElements: loadedRatingsPaged.totalElements
            )
            
            state = .content(loadedRecipeEssential, pagedRatingsWithPermissions)
            
            if loadedRatingsPaged.totalElements != 0 {
                loadRatingIndicator(recipeId: recipeId)
                loadMyRating(recipeId: recipeId, currentUser: currentUser)
            }
        }
    }
    
    private func loadPagedRatings(
        recipeId: Int64,
        page: Int,
        size: Int = 2,
        completion: @escaping (Result<RatingsPaged, NetworkError>) -> Void)
    {
        RecipeRatingService.shared.fetchAll(for: recipeId, page: page, size: size, completion: completion)
    }
    
    private func loadRecipeEssential(
        recipeId: Int64,
        completion: @escaping (Result<RecipeEssentialWithAuthor, NetworkError>) -> Void)
    {
        RecipeService.shared.fetchEssential(id: recipeId, completion: completion)
    }
    
    func loadRatingIndicator(recipeId: Int64) {
        RecipeRatingService.shared.fetchRatingIndicator(for: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let summary): self.indicatorState = .loaded(summary)
                case .failure(let networkError):
                    self.indicatorState = .error(message: networkError.userMessage)
                    self.alert = .error(title: "평가 요약 불러오기 오류", message: networkError.userMessage)
                }
            }
        }
    }
    
    func loadMyRating(recipeId: Int64, currentUser: CurrentUser?) {
        guard currentUser != nil else {
            myState = .loaded(nil)
            return
        }
        RecipeRatingService.shared.fetchMine(for: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.myState = .loaded(response)
                case .failure(let networkError):
                    self.myState = .error(message: networkError.userMessage)
                    self.alert = .error(title: "내 평가 불러오기 오류", message: networkError.userMessage)
                }
            }
        }
    }
    
    private func deleteRating(for id: Int64, isMine: Bool, recipeId: Int64) {
        guard case .content(let recipeEssential, var pagedRatingsWithPermissions) = state else { return }
        
        let index = pagedRatingsWithPermissions.items.firstIndex(where: { $0.id == id })
        var previousRating: RatingWithPermissions? = nil
        if let index = index {
            previousRating = pagedRatingsWithPermissions.items[index]
            pagedRatingsWithPermissions.remove(at: index)
            state = .content(recipeEssential, pagedRatingsWithPermissions)
        }
        
        let previousMyRatingState = myState
        if isMine { myState = .loaded(nil) } // '평가 안 함' 상태로 낙관적 업데이트 처리합니다.
        
        RatingService.shared.delete(for: id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadRatingIndicator(recipeId: recipeId)
                    self.alert = .deletionSuccess(isMine: isMine)
                case .failure(let networkError):
                    // 낙관적 업데이트된 항목을 롤백 처리합니다.
                    if let index = index, let previousRating = previousRating {
                        pagedRatingsWithPermissions.insert(previousRating, at: index)
                        self.state = .content(recipeEssential, pagedRatingsWithPermissions)
                    }
                    
                    if isMine { self.myState = previousMyRatingState }
                    self.alert = .error(title: "평가 삭제 실패", message: networkError.userMessage)
                }
            }
        }
    }
    
    private func createRatingsWithPermissions(for currentUser: CurrentUser?, from ratings: [Rating], _ recipeAuthorId: Int64) -> [RatingWithPermissions] {
        let newRatingsWithPermissions = ratings.map { rating in
            rating.toRatingWithPermissions(for: currentUser, recipeAuthorId: recipeAuthorId)
        }
        return newRatingsWithPermissions
    }
    
    private static func createSequentiallyError(
        from networkError: NetworkError,
        _ defaultMessage: String? = nil) -> (error: NetworkError, message: String) {
        if networkError.isServiceUnavailable {
            return (networkError, networkError.userMessage)
        } else if let defaultMessage = defaultMessage {
            return (networkError, "\(defaultMessage) \(networkError.userMessage)")
        } else {
            return (networkError, networkError.userMessage)
        }
    }
}

enum RatingState {
    case initialLoading
    case content(_ recipeEssential: RecipeEssentialWithAuthor, _ pagedRatingsWithPermissions: Paged<RatingWithPermissions>)
    case error(message: String)
}

enum RatingMyState: Equatable, Hashable {
    case initialLoading
    case loaded(Rating?)
    case error(message: String)
}

enum RatingMyStateOld: Equatable, Hashable {
    case initialLoading
    case loaded(Rating)
    case loadedNothing
    case error(message: String)
}

enum RatingIndicatorState: Equatable {
    case initialLoading
    case loaded(RatingIndicator)
    case error(message: String)
}

enum RatingDeleteActionType: Equatable, Identifiable {
    case mine(_ rating: Rating)
    case other(_ rating: Rating)

    var id: String {
        switch self {
        case .mine(let rating): return "delete_mine_\(rating.id)"
        case .other(let rating): return "delete_other_\(rating.id)"
        }
    }

    var rating: Rating {
        switch self {
        case .mine(let rating), .other(let rating):
            return rating
        }
    }

    var isMine: Bool {
        if case .mine = self { return true }
        return false
    }
}
