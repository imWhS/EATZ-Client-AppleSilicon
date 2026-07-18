//
//  PlannerGuestViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/5/26.
//

import SwiftUI

class PlannerViewModel: ObservableObject {
    /// 날짜 범위의 초기 기본 값입니다.
    /// - '오늘(호출한 시점)' 날짜를 시작으로 총 7일의 기간을 초기 날짜 범위 `dateRange`로 설정합니다.
    static var initialDateRange: (startDate: Date, endDate: Date) = {
        let now = Date()
        
        let today = Calendar.current.startOfDay(for: now)
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: today) ?? today
        return (today, endDate)
    }()
    
    /// 날짜 범위의 시작 날짜부터 종료 날짜까지 하루 단위로 연속된 날짜 배열을 생성합니다.
    static func generateDisplayDates(between dateRange: (startDate: Date, endDate: Date)) -> [Date] {
        let calendar = Calendar.current
        let endDate = dateRange.endDate
        var displayDates: [Date] = []
        var currentDate = dateRange.startDate
        
        while (currentDate <= endDate) {
            displayDates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return displayDates
    }
}
