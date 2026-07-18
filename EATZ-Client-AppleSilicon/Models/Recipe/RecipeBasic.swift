import Foundation

struct RecipeBasic: Equatable, Hashable, Codable, Identifiable {
    let id: Int64
    let title: String
    let imageUrl: String?
    let cookingTime: Int?
    let prepTime: Int?
    let authorId: Int64
    let authorUsername: String
    let ratingCount: Int?
    let ratingAverageScore: Double?
    var ownedByUser: Bool
    var likedByUser: Bool
    var savedByUser: Bool
}
