//
//  MainTabItemsData.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/10/25.
//

import Foundation

enum MainTabItemsData: String, CaseIterable, Identifiable {
    case explore
    case search
    case mypage
    case hello
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .explore: return "둘러보기"
        case .search: return "검색"
        case .mypage: return "마이페이지"
        case .hello: return "시작하기"
        }
    }
    
    var systemImage: String {
        switch self {
        case .explore: return "house"
        case .search: return "magnifyingglass"
        case .mypage: return "person.circle"
        case .hello: return "person.badge.plus"
        }
    }
}
