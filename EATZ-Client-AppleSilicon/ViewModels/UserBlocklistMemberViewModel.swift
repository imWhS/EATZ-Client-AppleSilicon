//
//  UserBlocklistViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import SwiftUI

class UserBlocklistMemberViewModel: ObservableObject {
    @Published var state: UserBlocklistMemberState = .initialLoading
    @Published var alert: UserBlocklistMemberAlert?
    
    var totalElementsLabel: String {
        if case .content(let pagedBlocklist) = state {
            return "\(pagedBlocklist.totalElements)명의 차단 사용자"
        } else {
            return "차단 사용자"
        }
    }
    
    private var isContentState: Bool {
        if case .content = state { return true
        } else { return false }
    }
    
    private let authManager: AuthManager
    
    // MARK: - 의존성 (Dependencies)
    
    private var member: CurrentUser? {
        self.authManager.currentUser
    }
    
    // MARK: - 초기화 (Initialization)
    
    init(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 컨텍스트나 뷰 상태 등을 먼저 확인해서, 필요한 경우에만 뷰 데이터를 불러옵니다.
    /// - 데이터 불러오기 진입점입니다.
    func prepareDataIfNeeded() {
        // 이미 뷰 데이터가 최소 한 번 불러와져 있는 경우(.content)엔 백그라운드에서 조용히 뷰 데이터를 업데이트합니다.
        // 뷰 데이터를 이미 불러오는 중(.loading)이었거나, 오류(.error)가 발생한 상황이었다면
        // 명시적으로 데이터를 불러오고 있는 상태임을 화면에 표시하기 위해 .loading으로 설정합니다.
        if !isContentState {
            state = .initialLoading
        }
        
        loadBlocklist()
    }
    
    /// 조건 없이 뷰 데이터를 불러와서 뷰를 새로 고칩니다.
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadBlocklist(completion: continuation.resume)
        }
    }
    
}

extension UserBlocklistMemberViewModel {
    func handleUnblockUser(for user: UserEssential) {
        alert = .confirmUnblock(username: user.username) {
            self.unblock(user: user)
        }
    }
    
    func unblock(user: UserEssential) {
        guard case .content(var pagedBlocklist) = state else { return }
        guard let index = pagedBlocklist.items.firstIndex(where: { $0.id == user.id }) else { return }
        
        let blockedUser = pagedBlocklist.items[index]
        pagedBlocklist.remove(at: index)
        state = .content(pagedBlocklist: pagedBlocklist)
        
        UserBlockService.shared.unblock(for: user.id) { result in
            if case .failure(let networkError) = result {
                guard case .content(var pagedBlocklist) = self.state else { return }
                guard let index = pagedBlocklist.items.firstIndex(where: { $0.id == user.id }) else { return }
                pagedBlocklist.insert(blockedUser, at: index)
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    func loadMoreBlocklist() {
        guard case .content(var pagedBlocklist) = state else { return }
        if pagedBlocklist.isLoadingNextPage { return }
        
        pagedBlocklist.isLoadingNextPage = true
        state = .content(pagedBlocklist: pagedBlocklist)
        
        loadBlocklist(page: pagedBlocklist.page + 1)
    }
    
    func loadBlocklist(page: Int = 0, completion: (() -> Void)? = nil) {
        UserBlockService.shared.getBlocklist(page: page, size: 10) { result in
            switch result {
            case .success(let response):
                var newPagedBlocklist: Paged<UserEssential>
                if case .content(let pagedBlocklist) = self.state { newPagedBlocklist = pagedBlocklist }
                else { newPagedBlocklist = .initial }
                    
                newPagedBlocklist.appendPage(
                    response.content,
                    page: response.page,
                    hasNextPage: response.hasNext,
                    totalElements: response.totalElements)
                
                self.state = .content(pagedBlocklist: newPagedBlocklist)
            case .failure(let networkError):
                if page == 0 {
                    self.state = .error(message: networkError.userMessage)
                } else {
                    self.alert = .error(message: networkError.userMessage)
                }
            }
            completion?()
        }
    }
}

enum UserBlocklistMemberState {
    case initialLoading
    case content(pagedBlocklist: Paged<UserEssential>)
    case error(message: String)
}
