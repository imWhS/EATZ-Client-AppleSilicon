//
//  ExploreSearchView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI

struct ExploreFiltersSection: View {
    let filters: ExploreFilters
    var action: (ExploreSheet) -> Void
    
    init(_ filters: ExploreFilters, onAction: @escaping (ExploreSheet) -> Void) {
        self.filters = filters
        self.action = onAction
    }
    
    private var totalTimeLabel: String {
        guard let totalMinutes = filters.totalTime else {
            return "설정"
        }
        
        if totalMinutes == 0 {
            return "0분"
        }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }
    
    private var servingsLabel: String {
        guard let servings = filters.servings else {
            return "설정"
        }
        
        return "\(servings)인"
    }
    
    var body: some View {
        HStack(alignment: .center) {
                ExploreFilterButton(totalTimeLabel, "최대 소요 시간") {
                    action(.totalTimePicker)
                }
                VerticalDivider(padding: 0)
                    .frame(maxHeight: 38)
                ExploreFilterButton(servingsLabel, "1회 제공량") {
                    action(.servingsPicker)
                }
            }
            .padding(.horizontal, 20)
    }
}
