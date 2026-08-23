//
//  ReportViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/22/26.
//

import SwiftUI

class ReportViewModel: ObservableObject {
    
    /// 메인 뷰 데이터인 신고 카테고리 목록 데이터 상태
    ///
    /// - 뷰는 신고 카테고리 목록 `[ReportCategories]`를 메인 뷰 데이터로 사용합니다.
    /// - 메인 뷰 데이터를 필요로 하는 서브뷰 등을 분기 처리하기 위해 사용합니다.
    /// - 뷰가 화면에 표시할 최상위 서브뷰를 결정하기 위해 사용할 수 있습니다.
    @Published var state: ReportState = .initialLoading
    
    @Published var category: ReportCategory?
    @Published var description: String = ""
    
    @Published var routingAction: ReportRoutingAction?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ReportAlert?
    
    @Published var isSubmitting: Bool = false
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    private var resource: ReportResource?
    
    /// 현재 사용자 정보입니다.
    private var currentUser: CurrentUser?
    
    /// 뷰 인스턴스 생성 시점에 필요한 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 뷰 최초 진입 시에만 메인 뷰 데이터를 불러옵니다.
    /// - 뷰의 인스턴스가 갓 만들어져서, 메인 뷰 데이터를 최초로 불러와야 할 때 사용할 수 있습니다.
    func loadInitial(_ resource: ReportResource, _ authManager: AuthManager) {
        guard case .initialLoading = state else { return }
        
        self.resource = resource
        load(authManager)
    }
    
    /// 메인 뷰 데이터를 불러옵니다.
    ///
    /// - 모든 뷰 상태 관련 프로퍼티를 `.initialLoading` 또는 `.idle`로 설정합니다.
    /// - 네트워크 오류 발생 등으로 인해 메인 뷰 데이터 상태가 `.error`일 떄, 메인 뷰 데이터 불러오기를 재시도 해야할 때 사용할 수 있습니다.
    func load(_ authManager: AuthManager?) {
        if !validateAndPrepareUser(authManager) { return }
        
        state = .initialLoading
        loadCategories()
    }
    
    /// 데이터를 불러올 필요성을 확인하기 위해 사용자를 검증하고, 검증 성공 시 현재 사용자 정보를 업데이트합니다.
    /// - 뷰를 화면에 표시하기 위한 데이터를 불러오기 전에, 현재 전역 인증 상태(사용자 변경, 데이터 유무)에 따라 필요한 사전 작업을 수행합니다.
    /// - 전역 로그인 상태가 아니면, 기존 사용자의 컨텍스트를 초기화합니다.
    ///   단, 재로그인 등으로 인해 로그인 사용자가 변경된 경우 기존 사용자의 컨텍스트를 초기화하고, 뷰를 dismiss 합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    func validateAndPrepareUser(_ authManager: AuthManager?) -> Bool {
        guard let authManager = authManager else { return false }
        
        if !authManager.isLoggedIn {
            handleContextAsGuest()
            return false
        }
        
        if let user = currentUser,
           user != authManager.currentUser {
            handleContextForNewUser()
            return false
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        state = .unauthorized
        clearAllContextData()
        alert = .sessionExpired {
            self.routingAction = .dismiss
        }
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        state = .unauthorized
        clearAllContextData()
        alert = .userChanged {
            self.routingAction = .dismiss
        }
    }
    
    private func clearAllContextData() {
        isSubmitting = false
        resource = nil
        currentUser = nil
        category = nil
        description = ""
    }
}

extension ReportViewModel {
    func handleSubmit() {
        alert = .confirmReport(confirmAction: submit)
    }
    
    private func loadCategories() {
        ReportService.shared.fetchCategories { result in
            switch result {
            case .success(let categories): self.state = .content(categories)
            case .failure(let networkError): self.state = .error(networkError.userMessage)
            }
        }
    }
    
    func submit() {
        guard case .content = state, let resource = resource, let category = category else { return }
        isSubmitting = true
        let request = ReportCreateRequest(
            resourceId: resource.id,
            resourceType: resource.type,
            categoryId: category.id,
            resourceContent: resource.content,
            description: description == "" ? nil : description)
        
        ReportService.shared.submit(request) { result in
            self.isSubmitting = false
            switch result {
            case .success: self.routingAction = .submitCompleted
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
}

/// 뷰 라우팅이 필요한 액션을 정의합니다.
enum ReportRoutingAction {
    case dismiss
    case submitCompleted
}
