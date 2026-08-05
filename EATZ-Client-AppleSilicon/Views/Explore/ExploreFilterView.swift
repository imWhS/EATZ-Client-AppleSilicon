//
//  ExploreSearchView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI

struct ExploreFilterView: View {
    let filters: ExploreFilters
    var onAction: (ExploreSheet) -> Void
    
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
                    onAction(.totalTimePicker)
                }
                VerticalDivider(padding: 0)
                    .frame(maxHeight: 38)
                ExploreFilterButton(servingsLabel, "1회 제공량") {
                    onAction(.servingsPicker)
                }
            }
            .padding(.horizontal, 20)
    }
}

private struct ExploreFilterButton: View {
    let label: String
    let subtitle: String
    let action: () -> Void
    
    init(_ label: String, _ subtitle: String, action: @escaping () -> Void) {
        self.label = label
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.black)
                    ArrowDownCircled24()
                }
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(CookableButtonHighlightStyle())
        .padding(.top, 10)
    }
}
