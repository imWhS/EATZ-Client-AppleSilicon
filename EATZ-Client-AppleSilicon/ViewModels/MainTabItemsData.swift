//
//  MainTabItems.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/10/25.
//

import Foundation

enum MainTab: String, CaseIterable, Identifiable {
    case recipe
    case search
    case mypage
    case hello
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .recipe: return "레시피"
        case .search: return "검색"
        case .mypage: return "마이페이지"
        case .hello: return "시작하기"
        }
    }
    
    var systemImage: String {
        switch self {
        case .recipe: return "house"
        case .search: return "magnifyingglass"
        case .mypage: return "person.circle"
        case .hello: return "person.badge.plus"
        }
    }
}
