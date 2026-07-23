//
//  EditProfileViewModelN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/29/25.
//

import SwiftUI
import PhotosUI
import Alamofire
import Combine

class ManagementProfileViewModel: ObservableObject {
    // MARK: - 뷰 상태 프로퍼티 (View State Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: ManagementProfileViewState = .initialLoading
    
    @Published var isProcessing: Bool = false
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: ManagementProfileSheet?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ManagementProfileAlert?
    
    // MARK: - 사용자 context 관련 프로퍼티
    
    @Published var username: String = ""
    @Published var imageUrl: String?
    @Published var bio: String = ""
    
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    
    /// 현재 사용자 정보입니다.
    private var currentUser: CurrentUser?
    
    // MARK: - 기본 설정 프로퍼티
    
    private var dismissAction: (() -> Void)?
    
    // MARK: - 기타 프로퍼티
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 의존성
    
    private lazy var authManager = AuthManager.shared
    
    init() {}
    
    /// 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 화면에 표시되고 있지 않던 뷰가 다시 화면에 표시되는 뷰 진입 시점에 주로 호출됩니다.
    func prepareDataIfNeeded() {
        subscribeToAuthState()
        
        // 로그인 사용자만 접근할 수 있는 뷰이기 때문에, 사용자 검증 실패 시 데이터를 불러오지 않습니다.
        if !validateAndPrepareUser() { return }
        
        // 불러오기 상태 설정 필요 여부를 확인합니다. 앱 실행 후 뷰가 한 번도 보여진 적 없었던 경우에만 실행합니다.
        if viewState != .content { viewState = .initialLoading }
        
        loadInitialData()
    }
    
    func setDismissAction(_ action: @escaping () -> Void) {
        dismissAction = action
    }
    
    private func loadInitialData() {
        let group = DispatchGroup()
        var errors: [(error: NetworkError, message: String)] = []
        let queue = DispatchQueue(label: "management_profile_error_queue")
        
        let loadCompletionHandler: (((NetworkError, String)?) -> Void) = { error in
            if let error = error {
                queue.sync { errors.append(error) }
            }
            group.leave()
        }
        
        group.enter()
        loadCurrentUserData(completion: loadCompletionHandler)
        
        group.enter()
        loadBio(completion: loadCompletionHandler)
        
        group.notify(queue: .main) { [weak self] in
            self?.handleLoadInitialDataCompletion(errors: errors)
        }
    }
    
    private func handleLoadInitialDataCompletion(errors: [(error: NetworkError, message: String)], completion: (() -> Void)? = nil) {
        defer { completion?() }
        
        if let error = errors.first(where: { $0.error.isServiceUnavailable }) {
            viewState = .error(message: error.message)
            return
        }
        
        if errors.count == 1, let error = errors.first {
            viewState = .error(message: error.1)
            return
        }
        
        if 1 < errors.count {
            viewState = .error(message: "필요한 정보 일부를 불러오지 못했어요.")
            return
        }
        
        viewState = .content
    }
    
    /// 전역 인증 상태를 구독합니다.
    /// - 뷰가 화면에 보여지고 있을 때, 비동기적인 전역 로그인 상태, 세션 만료 등 인증 상태 변경을 감지합니다.
    private func subscribeToAuthState() {
        guard cancellables.isEmpty else { return }
        
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .authenticated:
                    // 재로그인한 경우: 사용자 검증 및 데이터 불러오기를 위해 prepareDataIfNeeded를 다시 호출합니다.
                    self.prepareDataIfNeeded()
                case .unauthorized, .unknown:
                    // 전역 로그아웃 상태가 된 경우: 뷰를 표시할 필요가 없기 때문에, 데이터 불러오기를 하지 않고 즉시 컨텍스트 초기화 및 종료 알림을 처리합니다.
                    self.validateAndPrepareUser()
                }
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
        
        if let user = currentUser, user.id != authManager.currentUser?.id {
            handleContextForNewUser()
            return false
        }
        
        currentUser = authManager.currentUser
        return true
    }
    
    /// 전역 게스트 상태가 됐을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextAsGuest() {
        alert = .sessionExpired(dismissAction: dismissAction ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 이전과 다른 사용자로 변경했을 때, 화면에서 보여지기 위해 필요한 작업을 처리합니다.
    private func handleContextForNewUser() {
        alert = .userChanged(dismissAction: dismissAction ?? {})
        viewState = .unauthorized
        clearAllContextData()
    }
    
    /// 사용자 context 관련 프로퍼티의 값을 초기화합니다.
    private func clearAllContextData() {
        username = ""
        imageUrl = nil
        bio = ""
        currentUser = nil
    }
}

extension ManagementProfileViewModel {
    func setProcessing() {
        if case .content = viewState {
            isProcessing = true
        } else {
            isProcessing = false
        }
    }
    
    func handleDeleteProfileImage() {
        alert = .deleteImageConfirmation(confirmAction: deleteProfileImage)
    }
    
    func handleDeleteBio() {
        alert = .deleteBioConfirmation(confirmAction: deleteBio)
    }
    
    func handleEditBio() {
        sheet = .bioEditor
    }
    
    func updateCurrentUserBeforeDismiss() {
        authManager.performSessionValidation {
            self.dismissAction?()
        }
    }
    
    private func deleteProfileImage() {
        setProcessing()
        UserService.shared.deleteMyImage { [weak self] result in
            guard let self = self else { return }
            self.isProcessing = false
            
            switch result {
            case .success: self.alert = .imageDeleted(confirmAction: self.loadInitialData)
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    func handleProfileImageSelection() {
        guard let item = selectedPhotoItem else { return }
        
        Task {
            do {
                let uiImage = try await PhotosPickerItemUtility.toUIImage(for: item)
                let resizedUiImage = uiImage.resized(maxDimension: 512.0) ?? uiImage
                guard let jpegData = resizedUiImage.jpegData(compressionQuality: 0.8) else { return }
                DispatchQueue.main.async {
                    self.uploadProfileImage(jpegData)
                }
            } catch {
                self.alert = .error(message: "사진을 정상적으로 불러오지 못했어요.")
            }
        }
    }
    
    private func uploadProfileImage(_ data: Data) {
        setProcessing()
        UserService.shared.updateMyImage(imageData: data, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let response): self.imageUrl = response.imageUrl
                case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
                }
            }
            selectedPhotoItem = nil
        })
    }
    
    private func deleteBio() {
        setProcessing()
        UserService.shared.deleteMyBio { [weak self] result in
            self?.isProcessing = false
            switch result {
            case .success:
                self?.alert = .bioDeleted(confirmAction: self?.loadInitialData ?? {})
            case .failure(let networkError):
                self?.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func loadCurrentUserData(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserService.shared.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser):
                    self.username = currentUser.username
                    self.imageUrl = currentUser.imageUrl
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "회원님의 정보를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
    
    private func loadBio(completion: (((NetworkError, String)?) -> Void)? = nil) {
        UserService.shared.getMyBio { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.bio = response.bio ?? ""
                    completion?(nil)
                case .failure(let networkError):
                    let message = networkError.isServiceUnavailable ? networkError.userMessage : "회원님의 소개를 불러오지 못했어요. \(networkError.userMessage)"
                    completion?((networkError, message))
                }
            }
        }
    }
}

enum ManagementProfileViewState: Equatable {
    case initialLoading
    case content
    case error(message: String)
    case unauthorized
    
    static func == (lhs: ManagementProfileViewState, rhs: ManagementProfileViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initialLoading, .initialLoading): return true
        case (.content, .content): return true
        case (.unauthorized, .unauthorized): return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }
}
