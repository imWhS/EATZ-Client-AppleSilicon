//
//  Paged.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/15/25.
//

import Foundation

struct Paged<T> {
    var items: [T] = []
    var page: Int = 0
    var totalElements: Int = 0
    var hasNextPage: Bool = true
    var isLoadingNextPage: Bool = false
    
    var errorMessage: String? 
    
    var isEmpty: Bool { items.isEmpty }
    
    static var initial: Paged<T> {
        .init()
    }
    
    mutating func appendPage(_ newItems: [T], page: Int, hasNextPage: Bool, totalElements: Int) {
        if page == 0 {
            items = newItems
        } else {
            items.append(contentsOf: newItems)
        }
        
        self.page = page
        self.hasNextPage = hasNextPage
        self.totalElements = totalElements
        self.isLoadingNextPage = false
        self.errorMessage = nil
    }
    
    mutating func replace(with newItems: [T], totalCount: Int, page: Int, hasNextPage: Bool) {
        self.items = newItems
        self.totalElements = totalCount
        self.page = page
        self.hasNextPage = hasNextPage
    }
    
    mutating func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        self.items.remove(at: index)
        self.totalElements = max(0, totalElements - 1)
        
        /// 마지막 남은 항목을 삭제했을 때,  `hasNextPage`가 `false` 값을 유지해야 합니다.
        /// 삭제 후 초기 페이지 데이터를 불러오는 것과 같은 의도하지 않은 동작이 발생하지 않게 하기 위해서입니다.
        /// 그래서 해당 항목 삭제 후 `items`가 0개가 되더라도, `.initial` 처리를 하지 않습니다.
    }
    
    mutating func removeAll() {
        self = .initial
    }
    
    mutating func insert(_ item: T, at index: Int) {
        let currentIndex = min(max(0, index), items.count)
        self.items.insert(item, at: currentIndex)
        self.totalElements += 1
    }
}

extension Paged where T: Identifiable {
    mutating func updateItem(for id: T.ID, action: (inout T) -> Void) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            action(&items[index])
        }
    }
    
    mutating func remove(_ id: T.ID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            self.remove(at: index)
        }
        
        /// 마지막 남은 항목을 삭제했을 때,  `hasNextPage`가 `false` 값을 유지해야 합니다.
        /// 삭제 후 초기 페이지 데이터를 불러오는 것과 같은 의도하지 않은 동작이 발생하지 않게 하기 위해서입니다.
        /// 그래서 해당 항목 삭제 후 `items`가 0개가 되더라도, `.initial` 처리를 하지 않습니다.
    }
}
