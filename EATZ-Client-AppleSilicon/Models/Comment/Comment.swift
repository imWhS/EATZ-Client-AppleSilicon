//
//  Comment.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/25.
//

import Foundation

struct Comment: Identifiable, Codable, Equatable, Hashable {
    let id: Int64
    var content: String
    let author: UserEssential
    let isHidden: Bool
    let createdAt: Date
    let updatedAt: Date
    
    func permissions(
        for currentUser: CurrentUser?,
        recipeAuthorId: Int64
    ) -> Set<CommentPermission> {
        var result: Set<CommentPermission> = []
        
        guard let currentUser else { return result }
        
        if author.id == currentUser.id || recipeAuthorId == currentUser.id || currentUser.role == .ROLE_ADMIN {
            result.insert(.delete)
        }
        
        if author.id == currentUser.id {
            result.insert(.update)
        }
        
        if recipeAuthorId == currentUser.id {
            result.insert(.hide)
        }
        
        return result
    }
    
    func toCommentWithPermissions(
        for currentUser: CurrentUser?,
        recipeAuthorId: Int64?
    ) -> CommentWithPermissions {
        let permissions = getPermissions(for: currentUser, recipeAuthorId: recipeAuthorId)
        return CommentWithPermissions(self, permissions: permissions)
    }
    
    private func getPermissions(
        for currentUser: CurrentUser?,
        recipeAuthorId: Int64?
    ) -> Set<CommentPermission> {
        guard let currentUser = currentUser else { return [] }
        
        var result: Set<CommentPermission> = []
        
        let isMyComment = author.id == currentUser.id
        let isRecipeAuthor = recipeAuthorId == currentUser.id
        let isAdmin = currentUser.role == .ROLE_ADMIN
        
        if !isMyComment {
            result.insert(.block)
            result.insert(.report)
        }
        if isMyComment || isRecipeAuthor || isAdmin { result.insert(.delete) }
        if isMyComment { result.insert(.update) }
        if isRecipeAuthor { result.insert(.hide) }
        
        return result
    }
}

struct CommentWithPermissions: Identifiable, Equatable, Hashable {
    var comment: Comment
    let permissions: Set<CommentPermission>
    
    var id: Int64 { comment.id }
    
    init(_ comment: Comment, permissions: Set<CommentPermission>) {
        self.comment = comment
        self.permissions = permissions
    }
}

enum CommentPermission: String, Hashable, Identifiable {
    var id: String { rawValue }
    
    case delete
    case update
    case hide
    case block
    case report
}

