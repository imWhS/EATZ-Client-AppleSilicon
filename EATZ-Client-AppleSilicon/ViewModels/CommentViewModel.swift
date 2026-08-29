//
//  CommentViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/25.
//

import SwiftUI
import Combine

/**
 `CommentViewModel`은 `CommentView`에서 필요한 상태와 데이터를 관리하는 뷰 모델입니다.
 네트워크 통신을 통해 레시피 정보와 댓글 목록을 불러오고, 사용자의 상호작용에 따라 상태를 업데이트합니다.
 뷰는 이 뷰 모델의 `@Published` 프로퍼티를 구독하여 UI를 자동으로 업데이트할 수 있습니다.
 */
@MainActor
class CommentViewModel: ObservableObject {
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: CommentViewState = .initialLoading
    
    @Published var registrationState: CommentRegistrationState = .idle
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: CommentAlert?
    
    @Published var isEditorFocused: Bool = false
    @Published var editingCommentId: Int64?
    @Published var editingContent: String = ""
    @Published var initialContent: String?
    
    /// 댓글 목록
    @Published var pagedCommentsWithPermissions = Paged<CommentWithPermissions>()
    
    /// 차단하려는 사용자
    @Published var blockTargetUser: UserEssential?
    
    @Published var reportResource: ReportResource?
    
    /// 레시피 필수 정보
    @Published var recipeEssential: RecipeEssentialWithAuthor? {
        didSet {
            // 레시피 필수 정보 불러오기 완료 시, 기존 댓글 목록 내 모든 항복 권한도 다시 업데이트합니다.
            if !pagedCommentsWithPermissions.isEmpty { updateCommentsPermissions() }
        }
    }
    
    var navigationTitleLabel: String {
        if 0 < pagedCommentsWithPermissions.totalElements { return "\(pagedCommentsWithPermissions.totalElements)개의 댓글" }
        return "댓글"
    }
    
    /// 현재 댓글 편집 중 여부
    var isEditing: Bool { editingCommentId != nil }
    
    var currentUserImageUrl: String? { return currentUser?.imageUrl }
    
    var presentEditor: Bool {
        switch viewState {
        case .loaded: return true
        case .initialLoading, .error: return false
        }
    }
    
    var authManager: AuthManager? {
        didSet {
            currentUser = authManager?.currentUser
        }
    }
    
    var hasCommentUnsavedChanges: Bool {
        // 댓글 수정 상태인 경우
        if initialContent != nil { return initialContent != editingContent }
        // 새 댓글 등록 상태인 경우
        else { return !editingContent.isEmpty }
    }
    
    // MARK: - 비공개 프로퍼티 (Private Properties)
    
    /// 현재 보고 있는 레시피의 ID
    private let recipeId: Int64
    
    /// 현재 사용자
    private var currentUser: CurrentUser? {
        didSet {
            updateCommentsPermissions()
        }
    }
    
    /// 한 번에 불러올 댓글 수
    private let pagingSizeForCommentList = 2
    
    private var isLoadingState: Bool {
        if case .initialLoading = viewState { return true }
        return false
    }
    
    private var isErrorState: Bool {
        if case .error = viewState { return true }
        return false
    }
    
    // MARK: - 초기화 (Initialization)
    
    init(for recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    // MARK: - 공개 메서드 (Public Methods)
    
    /// 뷰의 생명 주기(`.onAppear`, `.task` 등)에서 화면에 표시 중인 데이터를 업데이트해야 할 필요가 있을 때에만 새로 불러옵니다.
    /// - 뷰를 화면에 표시하기 위한 사용자 검증 및 데이터 불러오기 진입점입니다.
    /// - 기존 불러온 데이터를 화면에 표시 중인지, 사용자가 이전과 동일한지 확인한 후,
    ///   화면에 표시 중인 데이터가 없거나 사용자가 변경된 경우에만 `resetAndLoadAll()`을 호출합니다.
    func prepareDataIfNeeded() {
        if !validateContext() { return }
        resetAndLoadAll()
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            self.loadAll(completion: continuation.resume)
        }
    }
    
    // MARK: - 비공개 메서드 (Private Methods)
    
    private func loadAll(completion: @escaping () -> Void = {}) {
        loadRecipeEssential { [weak self] in
            guard let self = self else { return }
            self.loadPagedComments(page: 0) {
                completion()
                self.viewState = .loaded
            }
        }
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티의 상태를 초기화하고, 필요한 모든 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    /// - `prepareDataIfNeeded`가 데이터를 업데이트해야 할 필요가 있다고 판단한 경우
    private func resetAndLoadAll() {
        registrationState = .idle
        if pagedCommentsWithPermissions.isEmpty {
            viewState = .initialLoading
            pagedCommentsWithPermissions = .initial
        }
        
        loadAll()
    }
    
    /// 데이터를 불러올 필요성을 검증합니다.
    /// - Returns:
    ///     - `true`: 검증에 성공해서 데이터를 불러올 필요가 있는 경우
    ///     - `false`: 검증에 실패해서 데이터를 불러오면 안 되는 경우
    private func validateContext() -> Bool {
        if case .loaded = viewState, !pagedCommentsWithPermissions.isEmpty { return false }
        return true
    }
}

extension CommentViewModel {
    /// 댓글 목록을 끝까지 스크롤했을 때, 댓글의 다음 페이지 데이터를 불러옵니다.
    func loadMoreComments() {
        // 다음 페이지가 있으며, 추가로 불러오고 있지 않을 때만 다음 페이지를 요청합니다.
        guard pagedCommentsWithPermissions.hasNextPage, !pagedCommentsWithPermissions.isLoadingNextPage else { return }
        pagedCommentsWithPermissions.isLoadingNextPage = true
        
        // 다음 페이지에 대한 댓글 목록을 요청합니다.
        loadPagedComments(page: pagedCommentsWithPermissions.page + 1) {
            self.pagedCommentsWithPermissions.isLoadingNextPage = false
        }
    }
    
    func startEditingComment(id: Int64) {
        authManager?.performWhenLoggedIn {
            if self.editingCommentId == id { return }
            
            if self.hasCommentUnsavedChanges {
                self.alert = .confirmChangeUpdatingComment(confirmAction: { self.activateEditor(for: id) })
            } else {
                self.activateEditor(for: id)
            }
        }
    }
    
    func cancelEditingComment() {
        if hasCommentUnsavedChanges { alert = .confirmDiscardChanges(confirmAction: resetEditor) }
        else { resetEditor() }
    }
    
    func handleSubmitEdit() {
        if let recipeEssential = recipeEssential, !(recipeEssential.commentEnabled) {
            alert = .commentDisabled
            return
        }
        
        let trimmedContent = editingContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        // 댓글 내용에 변경된 사항이 없으면, 바로 댓글 편집기를 초기화합니다.
        if initialContent == editingContent {
            resetEditor()
            return
        }
        
        if let id = editingCommentId { updateComment(for: id, content: trimmedContent) }
        else { registerComment(content: trimmedContent) }
    }
    
    func handleAction(_ comment: Comment, _ action: CommentItemAction) {
        switch action {
        case .block: handleBlockUser(comment.author)
        case .report: handleReport(for: comment)
        case .update: startEditingComment(id: comment.id)
        case .delete: handleDelete(for: comment)
        case .hide: break
        }
    }
    
    /// 댓글을 삭제하기 위한 사전 작업과 실제 삭제 요청을 처리합니다.
    ///
    /// 댓글을 삭제하기 전에 사용자 및 댓글 context 기반의 alert을 제공하기 위해 `Comment` 인스턴스가 필요합니다.
    private func handleDelete(for comment: Comment) {
        authManager?.performWhenLoggedIn { [weak self] in
            guard let self = self else { return }
            self.alert = .confirmDelete(
                type: comment.author.id == self.currentUser?.id ? .mine(comment: comment) : .other(comment: comment),
                confirmAction: { [weak self] in
                    self?.deleteComment(for: comment) } )
        }
    }
    
    private func handleBlockUser(_ targetUser: UserEssential) {
        blockTargetUser = targetUser
    }
    
    private func handleReport(for comment: Comment) {
        reportResource = ReportResource(
            id: comment.id,
            authorId: comment.author.id,
            authorUsername: comment.author.username,
            type: .COMMENT,
            content: comment.content)
    }
    
    /// 댓글 목록의 평가 별 제어 권한을 업데이트합니다.
    ///
    /// 기존 `pagedComments`의 원본 `Comment`을 바탕으로, 현재 로그인 사용자(`currentUser`)와
    /// 레시피 작성자 ID(`recipeEssential.authorId`) 상태에 맞게 댓글 별 제어 권한만 새롭게 계산 및 적용합니다.
    private func updateCommentsPermissions() {
        guard !pagedCommentsWithPermissions.isEmpty else { return }
        let commentsWithPermissions = pagedCommentsWithPermissions.items

        pagedCommentsWithPermissions.items = commentsWithPermissions.map { commentWithPermission in
            let comment = commentWithPermission.comment
            guard let recipeAuthorId = recipeEssential?.authorId else {
                return CommentWithPermissions(comment, permissions: [])
            }
            
            return comment.toCommentWithPermissions(for: self.currentUser, recipeAuthorId: recipeAuthorId)
        }
    }
    
    private func resetEditor() {
        initialContent = nil
        editingContent = ""
        editingCommentId = nil
        isEditorFocused = false
    }
    
    private func activateEditor(for id: Int64) {
        if let recipeEssential = recipeEssential, !(recipeEssential.commentEnabled) {
            alert = .commentDisabled
            return
        }
        
        guard let commentToEdit = pagedCommentsWithPermissions.items.first(where: { $0.id == id} )?.comment else { return }
        
        initialContent = commentToEdit.content
        editingContent = commentToEdit.content
        editingCommentId = commentToEdit.id
        isEditorFocused = true
    }
    
    /**
     댓글 목록을 당겨서 새로 고침할 때 호출됩니다. 댓글 목록을 처음부터 다시 불러옵니다.
     - Parameter completion: 새로고침 작업이 완료되었을 때 호출될 클로저입니다.
     */
    private func refreshCommentList(completion: @escaping () -> Void = {}) {
        pagedCommentsWithPermissions.page = 0 // 다음 페이지 불러오기와 새로 고침 간 충돌 방지
        pagedCommentsWithPermissions.isLoadingNextPage = false
        
        loadPagedComments(page: 0, completion: completion)
    }
    
    private func updateComment(for id: Int64, content: String) {
        if let recipeEssential = recipeEssential, !(recipeEssential.commentEnabled) {
            alert = .commentDisabled
            return
        }
        
        var originalContent: String?
        
        pagedCommentsWithPermissions.updateItem(for: id) { item in
            originalContent = item.comment.content // 실패 시 롤백에 사용합니다.
            item.comment.content = content
        }
        
        guard let originalConent = originalContent else {
            self.alert = .error(title: "댓글 수정 실패", message: "수정할 댓글을 찾을 수 없어요.")
            return
        }
        
        CommentService.shared.update(id: id, recipeId: self.recipeId, content: content) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let updatedComment):
                    self.pagedCommentsWithPermissions.updateItem(for: id) { $0.comment = updatedComment }
                    self.resetEditor()
                case .failure(let networkError):
                    self.pagedCommentsWithPermissions.updateItem(for: id) { $0.comment.content = originalConent }
                    self.alert = .error(title: "댓글 수정 실패", message: networkError.userMessage)
                }
            }
        }
    }
    
    /**
     네트워크를 통해 레시피의 필수 정보를 비동기적으로 불러옵니다.
     - Parameter completion: 데이터를 가져왔을 때 호출될 클로저입니다.
     */
    private func loadRecipeEssential(onSuccess: @escaping () -> Void) {
        RecipeService.shared.fetchEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                    onSuccess()
                case .failure(let networkError):
                    self.viewState = .error(message: networkError.userMessage)
                }
            }
        }
    }
    
    private func registerComment(content: String) {
        if let recipeEssential = recipeEssential, !(recipeEssential.commentEnabled) {
            alert = .commentDisabled
            return
        }
        
        guard !content.isEmpty, case .idle = registrationState else { return }
        guard let currentUser = self.authManager?.currentUser else { return }
        
        registrationState = .registering
        
        let dummyComment = Comment(
            id: Int64(Date().timeIntervalSince1970 * -1000),
            content: content,
            author: UserEssential(id: currentUser.id, username: currentUser.username, imageUrl: currentUser.imageUrl),
            isHidden: false,
            createdAt: .now,
            updatedAt: .now)
            .toCommentWithPermissions(for: currentUser, recipeAuthorId: recipeEssential?.authorId)
        
        pagedCommentsWithPermissions.items.insert(dummyComment, at: 0)
                
        RecipeCommentService.shared.register(for: recipeId, content: content) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let registeredComment):
                    self.pagedCommentsWithPermissions.updateItem(for: dummyComment.id) { $0.comment = registeredComment }
                    self.resetEditor()
                case .failure(let networkError):
                    // 낙관적 업데이트된 항목을 롤백합니다.
                    self.pagedCommentsWithPermissions.remove(dummyComment.id)
                    self.alert = .error(title: "댓글 등록 실패", message: networkError.userMessage)
                }
                self.registrationState = .idle
            }
        }
    }
    
    /**
     특정 페이지의 댓글 목록을 불러옵니다.
     */
    private func loadPagedComments(page: Int, completion: @escaping () -> Void = {}) {
        CommentService.shared.fetchAllPaged(id: recipeId, size: pagingSizeForCommentList, page: page) { [weak self] result in
            guard let self = self else { completion(); return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let comments = response.content
                    let commentsWithPermissions = comments.map { comment in
                        comment.toCommentWithPermissions(for: self.currentUser, recipeAuthorId: self.recipeEssential?.authorId) }
                    self.pagedCommentsWithPermissions.appendPage(
                        commentsWithPermissions,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements)
                case .failure(let networkError):
                    // 첫 페이지 불러오기에 실패한 경우에만 전체 화면을 에러 상태로 변경합니다.
                    if page == 0 && self.pagedCommentsWithPermissions.isEmpty {
                        self.pagedCommentsWithPermissions = .initial
                        self.viewState = .error(message: networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
                completion()
            }
        }
    }
    
    private func deleteComment(for comment: Comment) {
        // 삭제할 댓글의 인덱스와 데이터를 찾습니다. 롤백을 위해 저장해 둡니다.
        guard let index = pagedCommentsWithPermissions.items.firstIndex(where: { $0.id == comment.id }) else { return }
        
        let commentWithPermissions = pagedCommentsWithPermissions.items[index]
        pagedCommentsWithPermissions.remove(at: index)
        
        CommentService.shared.delete(id: comment.id, recipeId: self.recipeId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success:
                    let isMine = (self.authManager?.currentUser?.id == commentWithPermissions.comment.author.id)
                    self.alert = .deletionSuccess(isMine: isMine)
                case .failure(let networkError):
                    // 낙관적 업데이트된 항목을 롤백 처리합니다.
                    self.pagedCommentsWithPermissions.insert(commentWithPermissions, at: index)
                    self.alert = .error(title: "댓글 삭제 실패", message: networkError.userMessage)
                }
            }
        }
    }
}

enum CommentDeleteActionType: Equatable, Identifiable {
    case mine(comment: Comment)
    case other(comment: Comment)
    
    var id: String {
        switch self {
        case .mine(let r): return "delete_mine_\(r.id)"
        case .other(let r): return "delete_other_\(r.id)"
        }
    }
    
    var comment: Comment {
        switch self {
        case .mine(let comment), .other(let comment):
            return comment
        }
    }
    
    var isMine: Bool {
        if case .mine = self { return true }
        return false
    }
}

enum CommentRegistrationState: Equatable {
    case idle
    case registering
    case error(message: String)
}

enum CommentViewState {
    case initialLoading
    case loaded
    case error(message: String)
}

