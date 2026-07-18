//
//  MyIngredientsPantryViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/10/25.
//

import SwiftUI
import Combine

class MyIngredientPantryViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    @Published var viewState: MyIngredientPantryViewState = .loading
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: MyIngredientPantryAlert?
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: MyIngredientPantrySheet?
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    @Published var pagedIngredients: Paged<Ingredient> = .initial
    
    private var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private var dismissAction: (() -> Void)?
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성
    
    private lazy var authManager = AuthManager.shared
    
    func setDismissAction(_ action: @escaping () -> Void) {
        dismissAction = action
    }
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에 주로 호출됩니다.
    func prepareDataIfNeeded() {
        subscribeToPublishers()
        
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser() { return }
        
        // viewState가 .error일 때 등과 같이, 뷰에서 prepareDataIfNeeded를 다시 호출할 수도 있습니다.
        // 이때 사용자에게 데이터를 불러오고 있다는 피드백을 주기 위해 초기 데이터와 동일하더라도 viewState를 .loading으로 명시적으로 설정합니다.
        viewState = .loading
        
        loadIngredients()
    }
    
    func loadMoreIngredients() {
        guard pagedIngredients.hasNextPage
                && !pagedIngredients.isLoadingNextPage else { return }
        pagedIngredients.isLoadingNextPage = true
        
        loadIngredients(page: pagedIngredients.page + 1) {
            self.pagedIngredients.isLoadingNextPage = false }
    }
    
    func handleItemAction(action: IngredientItemAction) {
        switch action {
        case .like(let id): likeIngredient(id)
        case .unlike(let id): unlikeIngredient(id)
        case .addToPantry(let id): addIngredientToPantry(id)
        case .removeFromPantry(let id): removeIngredientFromPantry(id)
        }
    }
    
    func handleClearPantry() {
        self.alert = .clearPantryCaution(confirmAction: clearPantry)
    }
    
    private func loadIngredients(page: Int = 0, completion: @escaping () -> Void = {}) {
        UserPantryService.shared.fetchIngredients(page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let content = response.content
                    
                    if page == 0 && content.isEmpty {
                        self.pagedIngredients = .initial
                        self.viewState = .empty
                        break
                    }
                    
                    let ingredients = content.map { return Ingredient(from: $0) }
                    self.pagedIngredients.appendPage(ingredients, page: response.page, hasNextPage: response.hasNext, totalElements: response.totalElements)
                    self.viewState = .loaded
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedIngredients = .initial
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
    
    private func likeIngredient(_ id: Int64) {
        updateLikedStatus(for: id, isLiked: true)
        IngredientLikeService.shared.likeIngredient(for: id) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.updateLikedStatus(for: id, isLiked: false)
                self.alert = .likeFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func unlikeIngredient(_ id: Int64) {
        updateLikedStatus(for: id, isLiked: false)
        IngredientLikeService.shared.unlikeIngredient(for: id) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.updateLikedStatus(for: id, isLiked: true)
                self.alert = .unlikeFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func clearPantry() {
        UserPantryService.shared.clearIngredients { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.pagedIngredients = .initial
                self.viewState = .empty
            case .failure(let networkError):
                self.alert = .clearPantryFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func addIngredientToPantry(_ id: Int64) {
        updatePantryStatus(for: id, isOwned: true)
        UserPantryService.shared.addIngredients(ids: [id]) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.updatePantryStatus(for: id, isOwned: false)
                self.alert = .addToPantryFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func removeIngredientFromPantry(_ id: Int64) {
        updatePantryStatus(for: id, isOwned: false)
        UserPantryService.shared.removeIngredients(ids: [id]) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.updatePantryStatus(for: id, isOwned: true)
                self.alert = .addToPantryFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func updateLikedStatus(for id: Int64, isLiked: Bool) {
        pagedIngredients.updateItem(for: id) { item in
            item.likedByUser = isLiked
        }
    }
    
    private func updatePantryStatus(for id: Int64, isOwned: Bool) {
        pagedIngredients.updateItem(for: id) { item in
            item.ownedByUser = isOwned
        }
    }
    
    private func subscribeToPublishers() {
        guard cancellables.isEmpty else { return }
        
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                // 재로그인한 경우: 사용자 검증만 다시 진행합니다.
                // 전역 로그아웃 상태가 된 경우: 데이터 불러오기를 하지 않고, 즉시 컨텍스트 초기화 및 종료 알림을 처리합니다.
                self?.validateAndPrepareUser()
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
        if !authManager.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        if let user = currentUser,
           user.id != authManager.currentUser?.id {
            handleContextForNewUser()
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        viewState = .unauthorized
        alert = .sessionExpired(dismissAction: self.dismissAction ?? {})
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        viewState = .loading
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        pagedIngredients = .initial
        currentUser = nil
    }
}

enum MyIngredientPantryViewState: Equatable {
    case loading
    case loaded
    case empty
    case error(message: String)
    case unauthorized
}

enum MyIngredientPantrySheet: Identifiable {
    case ingredientPicker
    
    var id: String {
        switch self {
        case .ingredientPicker: return "ingredientPicker"
        }
    }
}

enum MyIngredientPantryAlert: Identifiable {
    case clearPantryCaution(confirmAction: () -> Void)
    case likeFailed(message: String)
    case unlikeFailed(message: String)
    case clearPantryFailed(message: String)
    case addToPantryFailed(message: String)
    case removeFromPantryFailed(message: String)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .clearPantryCaution: return "clearPantryCaution"
        case .likeFailed: return "likeFailed"
        case .unlikeFailed: return "unlikeFailed"
        case .clearPantryFailed: return "clearPantryFailed"
        case .addToPantryFailed: return "addToPantryFailed"
        case .removeFromPantryFailed: return "removeFromPantryFailed"
        case .sessionExpired: return "sessionExpired"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .clearPantryCaution(let confirmAction):
            return Alert(
                title: Text("재료 모두 제거"),
                message: Text("보관함의 모든 재료를 제거할까요?"),
                primaryButton: .destructive(Text("확인"), action: confirmAction),
                secondaryButton: .cancel(Text("취소"))
            )
        case .likeFailed(let message):
            return Alert(
                title: Text("재료 좋아요 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .unlikeFailed(let message):
            return Alert(
                title: Text("재료 좋아요 취소 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .addToPantryFailed(let message):
            return Alert(
                title: Text("보관함에 재료 추가 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .removeFromPantryFailed(let message):
            return Alert(
                title: Text("보관함에서 재료 제거 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        case .clearPantryFailed(let message):
            return Alert(
                title: Text("보관함의 모든 재료 제거 실패"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
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
