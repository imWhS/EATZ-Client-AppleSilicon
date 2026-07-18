import Foundation

struct ChecklistPlan: Equatable, Hashable, Decodable, Identifiable {
    var id: Int64
    let scheduledAt: Date
    let recipeId: Int64
    let recipeTitle: String
    let recipeImageUrl: String?
    let recipeCookingTime: Int?
    let recipePrepTime: Int?
    
    let recipeAuthorId: Int64
    let recipeAuthorUsername: String
    
    var ownedRecipeByUser: Bool
    var likedRecipeByUser: Bool
    var savedRecipeByUser: Bool
}
