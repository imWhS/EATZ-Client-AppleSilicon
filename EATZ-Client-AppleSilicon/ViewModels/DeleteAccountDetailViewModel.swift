//
//  UserBlocklistViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import SwiftUI

class DeleteAccountDetailViewModel: ObservableObject {
    @Published var state: DeleteAccountMemberState = .initialLoading
    @Published var alert: DeleteAccountMemberAlert?
    
    @Published var showNavigationBarTitle = false
    
    @Published var isPasswordVisible = false
    @Published var password: String = ""
    
    @Published var routingAction: DeleteAccountRoutingAction?
    
    private var isContentState: Bool {
        if case .content = state { return true
        } else { return false }
    }
    
    var authManager: AuthManager?
    
    // MARK: - 의존성 (Dependencies)
    
    private var member: CurrentUser? {
        authManager?.currentUser
    }
    
    // MARK: - 초기화 (Initialization)
    
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
        
        authManager?.performSessionValidation()
    }
}

extension DeleteAccountDetailViewModel {
    func deleteAccount() {
        guard let memberId = member?.id, !password.isEmpty else { return }
        UserService.shared.deactiveAccount(userId: memberId, existingPassword: password) { result in
            switch result {
            case .success:
                self.alert = .deleteCompleted(confirmAction: self.handleDeleteAccountCompletion)
            case .failure(let networkError):
                self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func handleDeleteAccountCompletion() {
        authManager?.logOut()
        routingAction = .dismiss
    }
}

enum DeleteAccountMemberState {
    case initialLoading
    case content(pagedBlocklist: Paged<UserEssential>)
    case error(message: String)
}

enum DeleteAccountRoutingAction {
    case dismiss
}
