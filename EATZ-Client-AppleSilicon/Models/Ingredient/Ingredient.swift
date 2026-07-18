//
//  Ingredient.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

/**
 IngredientPickerListItemView가 재료 정보를 표시하기 위해 필요한 UI 모델입니다.
 서버에서 받는 다양한 형태의 재료 DTO(예: Root, Child, SearchResult)를
 IngredientPickerListItemView가 쉽게 사용할 수 있는 단일한 형태로 변환할 수도 있습니다.
 */
struct Ingredient: Codable, Identifiable, Hashable, IngredientDisplayable {
    var id: Int64
    var name: String
    var hasChildren: Bool
    var ownedByUser: Bool
    var likedByUser: Bool
    
    init(from root: IngredientBasic) {
        self.id = root.id
        self.name = root.name
        self.hasChildren = root.hasChildren
        self.ownedByUser = root.ownedByUser
        self.likedByUser = root.likedByUser
    }
    
    init(from child: IngredientDetailResponse.Child) {
        self.id = child.id
        self.name = child.name
        self.hasChildren = child.hasChildren
        self.ownedByUser = child.ownedByUser
        self.likedByUser = child.likedByUser
    }
    
    func toIngredientEssential() -> IngredientEssential {
        return IngredientEssential(id: self.id, name: self.name)
    }
}
