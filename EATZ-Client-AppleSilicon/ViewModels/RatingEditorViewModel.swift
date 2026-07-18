//
//  RatingEditorViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/18/25.
//

import SwiftUI
import Alamofire
import Combine

/**
 뷰 초기화 및 초기화에 필요한 데이터의 불러오기 상태를 정의합니다.
 */
enum RatingEditorLoadState: Equatable {
    /// 서버로부터 데이터를 불러오는 중인 상태입니다.
    case loading
    
    /// 대기 상태입니다. 기본 값입니다.
    case idle
    
    /// 서버로부터 데이터를 가져와서, 해당 데이터를 이용해 화면에 평가 편집 화면을 정상적으로 표시할 준비가 완료된 상태입니다.
    case loaded
    
    /// 권한이 없거나 세션이 만료되어, 화면에 평가 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case unauthorized
    
    /// 서버로부터 데이터를 불러오는 과정에서 오류가 발생해 화면에 평가 편집 화면을 정상적으로 표시하지 못하는 상태입니다.
    case error(String)
    
    static func == (lhs: RatingEditorLoadState, rhs: RatingEditorLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.unauthorized, .unauthorized): return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }
}

/// RatingEditorView를 통해 레시피에 새 평가를 등록하거나, 기존 평가를 수정하기 위해 사용합니다.
///
/// 서버로부터 아래와 같은 데이터를 불러옵니다.
/// - 새 평가를 등록하거나, 기존의 평가를 수정할 대상 레시피의 요약 정보
/// - 기존 평가(평가를 수정하는 경우)
class RatingEditorViewModel: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 평가 대상 레시피의 요약 정보입니다.
    @Published var recipeEssential: RecipeEssentialWithAuthor?
    
    /// 사용자가 입력한 평점 상태입니다.
    @Published var score: Int
    
    /// 사용자가 입력한 평가 내용 상태입니다.
    @Published var content: String
    
    /// 평가 제출 상태입니다.
    @Published var submissionState: RatingEditorSubmissionState = .idle
    
    /// 초기 데이터 불러오기 상태
    @Published var loadState: RatingEditorLoadState = .idle
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: RatingEditorAlert?
    
    var navigationTitleLabel: String {
        isEditMode ? "평가 편집" : "새 평가"
    }
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    private var initialUsername: String?
    private var initialScore: Int = 0
    private var initialContent: String = ""
    private var onSubmitCompleted: () -> Void
    
    /// 기존 평가 데이터
    ///
    /// 수정 모드일 경우에만 존재하며, 새 평가를 작성하는 경우 `nil`이 됩니다.
    private var existingRating: Rating?
    
    private var isEditMode: Bool {
        existingRating != nil
    }
    
    // MARK: - 의존성 (Dependencies)
    // 이 뷰 모델이 동작하기 위해 필요한 외부 서비스나 관리자 객체들입니다.
    
    private let auth: AuthProvider
    private let recipeId: Int64
    private var cancellables = Set<AnyCancellable>()
    private var dismissAction: (() -> Void)?
    
    /// 사용자가 입력한 평점, 평가 내용 등의 상태들이 초기에 불러온 데이터 대비 변경 사항이 존재하는지에 대한 여부를 나타냅니다.
    private var hasUnsavedChanges: Bool {
        return initialScore != score || initialContent != content
    }
    
    // MARK: - 초기화 (Initialization)
    
    init(recipeId: Int64, existing: Rating? = nil, onSubmitCompleted: @escaping () -> Void, auth: AuthProvider = AuthManager.shared) {
        self.auth = auth
        self.recipeId = recipeId
        self.score = existing?.score ?? 0
        self.content = existing?.content ?? ""
        self.onSubmitCompleted = onSubmitCompleted
        
        // 뷰가 불러와졌을 때의 사용자 이름을 보관해둡니다.
        setInitialUsernameFromAuthManager()
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    func setDismissAction(_ action: @escaping () -> Void) {
        dismissAction = action
    }
    
    /// 사용자의 비동기적인 인증 상태 변경 및 세션 만료 상태를 실시간으로 감지하기 위해 `AuthManager`의 `authState` 프로퍼티를 구독합니다.
    func subscribeToAuthState() {
        guard let authManager = auth as? AuthManager else { return }
        authManager.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .authenticated(let user):
                    // 게스트 상태에서 로그인 상태로 변경됐을 때
                    if self.initialUsername != nil && self.initialUsername != user.username {
                        // RatingEditorView가 처음 불러와졌을 때와 다른 사용자로 로그인된 경우, 관련 alert을 화면에 표시합니다.
                        self.alert = .userChanged(dismissAction: self.dismissAction ?? {})
                    }
                case .unauthorized, .unknown:
                    self.loadState = .unauthorized
                    
                    // 로그인 상태에서만 접근할 수 있는 뷰가 화면에 보여지고 있는 상태에서, 게스트 상태로의 변경이 감지된 경우
                    // 세션 만료로 간주해서 관련 alert를 띄웁니다.
                    self.alert = .sessionExpired(dismissAction: self.dismissAction ?? {})
                }
            }
            .store(in: &cancellables)
    }
    
    
    /// 뷰를 화면에 표시하기 위해 필요한 데이터를 불러오기하고, 뷰 실행 환경을 구성하기 위한 준비 작업을 시작합니다.
    /// - 뷰가 화면에 나타나는 시점에 한 번 호출되어야 합니다. 그래서 `loadState`가 `.idle`이 아니면 실행을 중단합니다.
    /// - 호출 직후, 화면에 표시하기 위해 필요한 데이터 불러오기가 시작됨을 알리기 위해, `loadState`를 `.loading`으로 설정합니다.
    func prepare() {
        guard loadState == .idle else { return }
        loadState = .loading
        
        if initialUsername == nil {
            setInitialUsernameFromAuthManager()
        }
        
        loadRecipeEssential {
            self.loadExistingRating {
                self.loadState = .loaded
            }
        }
    }

    /// 평가를 서버에 제출합니다.
    /// - `isEditMode`가 `true`인 경우, 기존 평가 수정(update)을 요청하며, `false`인 경우, 대상 레시피에 새 평가를 등록(register)합니다.
    func submit() {
        if submissionState == .submitting {
           print("[RatingEditorViewModel.submit] 이미 평가를 제출하고 있어서 실행을 종료할게요.")
           return
       }
        
        guard score > 0 else {
            alert = .scoreNotSelected(confirmAction: { self.submissionState = .idle })
            return
        }
        
        submissionState = .submitting
        
        let completion: (Result<Alamofire.Empty, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.submissionState = .idle
                switch result {
                case .success:
                    self.onSubmitCompleted()
                case .failure(let networkError):
                    self.alert = .error(message: networkError.userMessage)
                }
            }
        }
        
        if isEditMode {
            guard let existingRating = existingRating else { return }
            RatingService.shared.update(
                for: existingRating.id,
                score: score,
                content: content,
                completion: completion)
        } else {
            RecipeRatingService.shared.register(
                for: recipeId,
                score: score,
                content: content,
                completion: completion)
        }
    }
    
    /// `NavigationBar`의 `ToolbarItem` 중 취소('✕')  버튼을 탭했을 때의 동작을 처리합니다.
    /// - 기본적으로 뷰를 dismiss 합니다.
    /// - 변경 또는 추가 내용이 있으면 해당 내용과 관련한 alert을 present합니다.
    func handleCancelAction() {
        if hasUnsavedChanges {
            alert = .hasUnsavedChanges(confirmAction: dismissAction ?? {})
        } else {
            dismissAction?()
        }
    }
    
    /// 평가 대상인 레시피의 요약 정보 데이터를 서버로부터 불러옵니다.
    private func loadRecipeEssential(onSuccess: (() -> Void)? = nil) {
        RecipeService.shared.fetchEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                    onSuccess?()
                case .failure(let networkError):
                    self.loadState = .error(networkError.userMessage)
                }
            }
        }
    }
    
    /// 사용자의 기존 평가 데이터를 서버로부터 불러옵니다.
    /// - 사용자가 새 평가를 등록하는 것인지, 기존 평가를 수정하는 것인지 확인하기 위해 필요합니다.
    private func loadExistingRating(onComplete: (() -> Void)? = nil) {
        guard auth.isLoggedIn else {
            loadState = .unauthorized
            return
        }
        
        RecipeRatingService.shared.fetchMine(for: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let rating):
                    self.configureRating(with: rating)
                    onComplete?()
                case .failure(let networkError):
                    self.loadState = .error(networkError.localizedDescription)
                }
            }
        }
    }
    
    /// 서버로부터 불러오기한 평가 데이터를 UI에 표시하기 위한 상태와 binding 합니다.
    /// 또한, 사용자에 의한 평가 데이터 변경 감지에 필요한 프로퍼티의 초기 값을 설정합니다.
    private func configureRating(with rating: Rating?) {
        existingRating = rating
        
        guard let existingRating = rating else {
            initialScore = 0
            initialContent = ""
            return
        }
        
        score = existingRating.score
        content = existingRating.content
        
        initialScore = score
        initialContent = content
    }
    
    private func setInitialUsernameFromAuthManager() {
        if let currentUser = auth.currentUser {
            initialUsername = currentUser.username
        }
    }
}
