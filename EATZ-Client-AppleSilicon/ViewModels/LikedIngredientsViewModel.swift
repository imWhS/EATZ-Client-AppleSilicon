//
//  LikedIngredientsViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/5/25.
//

import SwiftUI
import Combine

class LikedIngredientsViewModel: ObservableObject {
    @Published var pagedIngredients: Paged<Ingredient> = .initial
    
    @Published var alert: LikedIngredientsAlert?
    @Published var viewState: LikedIngredientsViewState = .loading
        
    private var initialUsername: String?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var authManager = AuthManager.shared
    
    init() {
        checkAuthStatus()
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    func resetAndLoadAll() {
        if case .authenticated = authManager.state {
            viewState = .loading
            loadLikedIngredients()
        } else {
            viewState = .unauthorized
        }
    }
    
    func loadMoreLikedIngredients() {
        guard !pagedIngredients.isLoadingNextPage, pagedIngredients.hasNextPage else { return }
        pagedIngredients.isLoadingNextPage = true
        loadLikedIngredients(page: pagedIngredients.page + 1) {
            self.pagedIngredients.isLoadingNextPage = false
        }
    }
    
    func subscribeToAuthState() {
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .authenticated(let user):
                    // 게스트 상태에서 로그인 상태로 변경됐을 때
                    if self.initialUsername != nil && self.initialUsername != user.username {
                        // MyAccountView가 처음 불러와졌을 때와 다른 사용자로 로그인된 경우: 일단 별도 처리를 진행하지 않습니다.
                        self.loadLikedIngredients()
                    } else {
                        self.loadLikedIngredients()
                    }
                case .unauthorized, .unknown:
                    self.viewState = .unauthorized
                }
            }
            .store(in: &cancellables)
    }
    
    func loadLikedIngredients(page: Int = 0, completion: @escaping () -> Void = {}) {
        UserService.shared.fetchLikedIngredients(page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            
            switch result {
            case .success(let response):
                let ingredients = response.content.map { return Ingredient(from: $0) }
                
                if page == 0 && ingredients.isEmpty {
                    self.pagedIngredients = .initial
                    self.viewState = .empty
                    break
                }
                
                self.pagedIngredients.appendPage(
                    ingredients,
                    page: response.page,
                    hasNextPage: response.hasNext,
                    totalElements: response.totalElements)
                self.viewState = .loaded
            case .failure(let networkError):
                if page == 0 {
                    self.pagedIngredients = .initial
                    self.viewState = .error(networkError.userMessage)
                } else {
                    self.alert = .error(message: networkError.userMessage)
                    self.viewState = .loaded
                }
            }
            completion()
        }
    }
    
    func handleItemAction(_ action: IngredientItemAction) {
        switch action {
        case .like(let id): likeIngredient(id)
        case .unlike(let id): unlikeIngredient(id)
        case .addToPantry(let id): addIngredientToPantry(id)
        case .removeFromPantry(let id): removeIngredientFromPantry(id)
        }
    }
    
    private func likeIngredient(_ id: Int64) {
        pagedIngredients.updateItem(for: id) { $0.likedByUser = true }
        IngredientLikeService.shared.likeIngredient(for: id) { result in
            if case .failure(let networkError) = result {
                self.pagedIngredients.updateItem(for: id) { $0.likedByUser = false }
                self.alert = .likeFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func unlikeIngredient(_ id: Int64) {
        pagedIngredients.updateItem(for: id) { $0.likedByUser = false }
        IngredientLikeService.shared.unlikeIngredient(for: id) { result in
            if case .failure(let networkError) = result {
                self.pagedIngredients.updateItem(for: id) { $0.likedByUser = true }
                self.alert = .unlikeFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func addIngredientToPantry(_ id: Int64) {
        pagedIngredients.updateItem(for: id) { $0.ownedByUser = true }
        UserPantryService.shared.addIngredients(ids: [id]) { result in
            if case .failure(let networkError) = result {
                self.pagedIngredients.updateItem(for: id) { $0.ownedByUser = false }
                self.alert = .addToPantryFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func removeIngredientFromPantry(_ id: Int64) {
        pagedIngredients.updateItem(for: id) { $0.ownedByUser = false }
        UserPantryService.shared.removeIngredients(ids: [id]) { result in
            if case .failure(let networkError) = result {
                self.pagedIngredients.updateItem(for: id) { $0.ownedByUser = true }
                self.alert = .removeFromPantryFailed(message: networkError.userMessage)
            }
        }
    }
    
    private func checkAuthStatus() {
        if let currentUser = authManager.currentUser {
            initialUsername = currentUser.username
        } else {
            viewState = .unauthorized
        }
    }
}

enum LikedIngredientsViewState {
    case loading
    case loaded
    case empty
    case unauthorized
    case error(String)
}

enum LikedIngredientsAlert: Identifiable {
    case likeFailed(message: String)
    case unlikeFailed(message: String)
    case addToPantryFailed(message: String)
    case removeFromPantryFailed(message: String)
    case error(message: String)
    
    var id: String {
        switch self {
        case .likeFailed: return "likeFailed"
        case .unlikeFailed: return "unlikeFailed"
        case .addToPantryFailed: return "addToPantryFailed"
        case .removeFromPantryFailed: return "removeFromPantryFailed"
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
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
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

