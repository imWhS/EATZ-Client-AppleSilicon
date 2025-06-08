//
//  RecipeListItem.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct RecipeListItem: Equatable, Hashable, Decodable, Identifiable {
    
    let id: Int64
    
    let title: String
    
    let imageUrl: String?
    
    let cookingTime: Int?
    
    let prepTime: Int?
    
    let createdAt: String
    
    let updatedAt: String
    
    let viewCount: Int
    
    let author: RecipeListItem.Author
    
    let commentCount: Int
    
    let likedCount: Int
    
    let savedByUser: Bool
    
    let savedCount: Int64
    
    let ingredients: [IngredientListItem]
    
    let categories: [CategoryListItem]
    
    let ratingCount: Int
    
    let averageRatingScore: Double?
    
    let likedByUser: Bool?
    
    struct Author: Equatable, Hashable, Decodable {
        
        let id: Int64
        let username: String
        let imageUrl: String?
        
    }
    
}
