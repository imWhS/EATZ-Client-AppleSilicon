//
//  Rating.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct Rating: Identifiable, Codable, Hashable {
    let id: Int64
    let score: Int
    let content: String
    let author: UserEssential
    let createdAt: Date
    let updatedAt: Date
    
    init() {
        self.id = -1
        self.author = UserEssential(id: -1, username: "", imageUrl: nil)
        self.score = 0
        self.content = ""
        self.createdAt = .now
        self.updatedAt = .now
    }
    
    func toRatingWithPermissions(
        for currentUser: CurrentUser?,
        recipeAuthorId: Int64?
    ) -> RatingWithPermissions {
        let permissions = getPermissions(for: currentUser, recipeAuthorId: recipeAuthorId)
        return RatingWithPermissions(self, permissions: permissions)
    }
    
    private func getPermissions(
        for currentUser: CurrentUser?,
        recipeAuthorId: Int64?
    ) -> Set<RatingPermission> {
        guard let currentUser = currentUser else { return [] }
        var result: Set<RatingPermission> = []
        
        let isMyRating = author.id == currentUser.id
        let isRecipeAuthor = recipeAuthorId == currentUser.id
        let isAdmin = currentUser.role == .ROLE_ADMIN
        
        if isMyRating || isRecipeAuthor || isAdmin { result.insert(.delete) }
        if !isMyRating {
            result.insert(.block)
            result.insert(.report)
        }
        if isMyRating { result.insert(.update) }
        if isRecipeAuthor { result.insert(.hide) }
        
        return result
    }
}

struct RatingWithPermissions: Identifiable, Equatable {
    let rating: Rating
    let permissions: Set<RatingPermission>
    
    var id: Int64 { rating.id }
    
    init(_ rating: Rating, permissions: Set<RatingPermission>) {
        self.rating = rating
        self.permissions = permissions
    }
}

enum RatingPermission: Hashable {
    case delete
    case update
    case hide
    case block
    case report
}
