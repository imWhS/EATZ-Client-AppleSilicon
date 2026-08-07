//
//  KitchenwarePickerViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI
import Combine

/// 기존 도구 구성을 편집하기 위해, 도구 목록을 통해 1개 이상의 도구를
/// 선택 또는 해제할 수 있는 뷰 KitchenwarePicker에서 필요한 데이터와 로직을 제공합니다.
class KitchenwarePickerViewModel: ObservableObject, SelectableKitchenwareManager {
    
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    @Published var viewState: SelectableKitchenwareViewState = .loading
    @Published var searchState: SelectableKitchenwareSearchState = .searching
    @Published var pagedKitchenwares: Paged<Kitchenware> = .initial
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: SelectableKitchenwareAlert?
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    @Published var searchKeyword = ""
    @Published var pagedSearchedKitchenwares: Paged<Kitchenware> = .initial
    @Published var selectedKitchenwares: [KitchenwareEssential] = []
    
    private var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private var onDismiss: (() -> Void)?
    
    /// 최종 선택된 도구 목록입니다.
    /// - 상위 뷰와 binding됩니다.
    private var selectionBinding: Binding<[KitchenwareEssential]>
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성
    
    private lazy var authManager = AuthManager.shared
    
    init(initialSelection: Binding<[KitchenwareEssential]>) {
        self.selectionBinding = initialSelection
        self._selectedKitchenwares = Published(initialValue: initialSelection.wrappedValue)
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
        
        loadKitchenwares()
    }
    
    func setDismissAction(_ action: @escaping () -> Void) {
        onDismiss = action
    }
    
    func complete() {
        selectionBinding.wrappedValue = self.selectedKitchenwares
        onDismiss?()
    }
    
    func toggleSelection(for item: Kitchenware) {
        if isSelected(item.id) {
            selectedKitchenwares.removeAll { $0.id == item.id }
        } else {
            let selectedItem = item.toKitchenwareItem()
            selectedKitchenwares.insert(selectedItem, at: 0)
        }
    }
    
    func toggleSelection(for kitchenware: KitchenwareEssential) {
        if isSelected(kitchenware.id) {
            selectedKitchenwares.removeAll { $0.id == kitchenware.id }
        } else {
            let selectedKitchenware = kitchenware
            selectedKitchenwares.insert(selectedKitchenware, at: 0)
        }
    }
    
    func isSelected(_ id: Int64) -> Bool { selectedKitchenwares.contains { $0.id == id } }
    
    func isDisabled(_ item: Kitchenware) -> Bool { false }
    
    func loadMoreKitchenwares() {
        guard pagedKitchenwares.hasNextPage
                && !pagedKitchenwares.isLoadingNextPage else { return }
        
        pagedKitchenwares.isLoadingNextPage = true
        loadKitchenwares(page: pagedKitchenwares.page + 1) {
            self.pagedKitchenwares.isLoadingNextPage = false
        }
    }
    
    func loadMoreSearchedKitchenwares() {
        guard pagedSearchedKitchenwares.hasNextPage,
              !pagedSearchedKitchenwares.isLoadingNextPage,
              !searchKeyword.isEmpty else { return }
        
        pagedSearchedKitchenwares.isLoadingNextPage = true
        searchKitchenwares(keyword: searchKeyword, page: pagedSearchedKitchenwares.page + 1) {
            self.pagedSearchedKitchenwares.isLoadingNextPage = false
        }
    }
    
    func loadKitchenwares(page: Int = 0, completion: @escaping () -> Void = {}) {
        KitchenwareService.shared.fetchAllKitchenwares(page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            if case .unauthorized = self.viewState { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let kitchenwares = response.content.map { return Kitchenware(from: $0) }
                    
                    if page == 0 && kitchenwares.isEmpty {
                        self.pagedKitchenwares = .initial
                        self.viewState = .empty
                        break
                    }
                   
                    self.pagedKitchenwares.appendPage(
                        kitchenwares,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements)
                    self.viewState = .loaded
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedKitchenwares = .initial
                        self.viewState = .error(networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                        self.viewState = .loaded
                    }
                }
                
                completion()
            }
        }
    }
    
    func searchKitchenwares(keyword: String, page: Int = 0, completion: @escaping () -> Void = {}) {
        KitchenwareService.shared.search(name: keyword, page: page, size: 10) { [weak self] result in
            guard let self = self else { completion(); return }
            if case .unauthorized = self.viewState { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let content = response.content
                    
                    if page == 0 && content.isEmpty {
                        self.pagedSearchedKitchenwares = .initial
                        self.searchState = .empty
                        break
                    }
                    
                    let searchedKitchenwares = content.map { return Kitchenware(from: $0) }
                    self.pagedSearchedKitchenwares.appendPage(
                        searchedKitchenwares,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements)
                    self.searchState = .searched
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedSearchedKitchenwares = .initial
                        self.searchState = .error(networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                        self.searchState = .searched
                    }
                }
                completion()
            }
        }
    }
    
    private func handleSearchInput(keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        // 검색어가 비어 있으면 검색 결과를 비우고 도구 목록을 불러옵니다.
        if trimmedKeyword.isEmpty {
            pagedSearchedKitchenwares = .initial
            // pagedIngredients가 비어있을 경우에만 도구 목록을 다시 불러옵니다.
            if pagedKitchenwares.isEmpty {
                loadKitchenwares()
            }
        } else {
            // 검색어가 있으면 검색 API를 호출합니다.
            searchState = .searching
            searchKitchenwares(keyword: trimmedKeyword)
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
        
        $searchKeyword
            // 0.5초 동안 사용자의 입력이 없으면 다음 단계를 실행합니다.
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            // 중복된 검색어는 무시합니다.
            .removeDuplicates()
            .sink { [weak self] keyword in
                self?.handleSearchInput(keyword: keyword)
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
            return false
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        alert = .sessionExpired(dismissAction: onDismiss ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        alert = .userChanged(dismissAction: onDismiss ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        searchKeyword = ""
        pagedSearchedKitchenwares = .initial
        selectedKitchenwares = []
        currentUser = nil
    }
}

